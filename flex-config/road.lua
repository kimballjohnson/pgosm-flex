require "helpers"

local tables = {}

tables.road_point = osm2pgsql.define_table({
    name = 'road_point',
    schema = schema_name,
    ids = { type = 'node', id_column = 'osm_id' },
    columns = {
        { column = 'osm_type',     type = 'text', not_null = true },
        { column = 'name',     type = 'text' },
        { column = 'ref',     type = 'text' },
        { column = 'maxspeed', type = 'int' },
        { column = 'oneway',     type = 'direction' },
        { column = 'layer',   type = 'int', not_null = true },
        { column = 'tunnel',     type = 'text' },
        { column = 'bridge',     type = 'text' },
        { column = 'geom',     type = 'point', projection = srid }
    }
})



tables.road_line = osm2pgsql.define_table({
    name = 'road_line',
    schema = schema_name,
    ids = { type = 'way', id_column = 'osm_id' },
    columns = {
        { column = 'osm_type',     type = 'text', not_null = true },
        { column = 'major',   type = 'boolean', not_null = true},
        { column = 'name',     type = 'text' },
        { column = 'ref',     type = 'text' },
        { column = 'maxspeed', type = 'int' },
        { column = 'oneway',     type = 'direction' },
        { column = 'layer',   type = 'int', not_null = true },
        { column = 'tunnel',     type = 'text' },
        { column = 'bridge',     type = 'text' },
        { column = 'geom',     type = 'linestring', projection = srid }
    }
})




function road_process_node(object)
    if not object.tags.highway then
        return
    end

    local name = get_name(object.tags)
    local osm_type = object:grab_tag('highway')
    local ref = object:grab_tag('ref')

    -- in km/hr
    local maxspeed = parse_speed(object.tags.maxspeed)
    local oneway = object:grab_tag('oneway') or 0
    local layer = parse_layer_value(object.tags.layer)
    local tunnel = object:grab_tag('tunnel')
    local bridge = object:grab_tag('bridge')

    tables.road_point:add_row({
        name = name,
        osm_type = osm_type,
        ref = ref,
        maxspeed = maxspeed,
        oneway = oneway,
        layer = layer,
        tunnel = tunnel,
        bridge = bridge,
        geom = { create = 'point' }
    })

end

function road_process_way(object)
    if not object.tags.highway then
        return
    end

    local name = get_name(object.tags)
    local osm_type = object:grab_tag('highway')
    local ref = object:grab_tag('ref')

    -- in km/hr
    local maxspeed = parse_speed(object.tags.maxspeed)
    local oneway = object:grab_tag('oneway') or 0
    local major = major_road(osm_type)
    local layer = parse_layer_value(object.tags.layer)
    local tunnel = object:grab_tag('tunnel')
    local bridge = object:grab_tag('bridge')

    tables.road_line:add_row({
        name = name,
        osm_type = osm_type,
        ref = ref,
        maxspeed = maxspeed,
        oneway = oneway,
        major = major,
        layer = layer,
        tunnel = tunnel,
        bridge = bridge,
        geom = { create = 'line' }
    })

end


if osm2pgsql.process_node == nil then
    -- Change function name here
    osm2pgsql.process_node = road_process_node
else
    local nested = osm2pgsql.process_node
    osm2pgsql.process_node = function(object)
        local object_copy = deep_copy(object)
        nested(object)
        -- Change function name here
        road_process_node(object_copy)
    end
end


if osm2pgsql.process_way == nil then
    -- Change function name here
    osm2pgsql.process_way = road_process_way
else
    local nested = osm2pgsql.process_way
    osm2pgsql.process_way = function(object)
        local object_copy = deep_copy(object)
        nested(object)
        -- Change function name here
        road_process_way(object_copy)
    end
end
