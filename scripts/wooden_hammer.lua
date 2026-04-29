function on_use_on_block(x, y, z)
    if block.get(x, y, z) == block.index("newgen:hay_roof") then
        if block.get_variant(x, y, z) == 0 then
            block.set_variant(x, y, z, 1)
        else
            block.set_variant(x, y, z, 0)
        end
    end
end