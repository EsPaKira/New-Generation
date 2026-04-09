local health_system = entity:require_component("newgen:health_system")

function on_attacked()
    health_system.damage(1)
end