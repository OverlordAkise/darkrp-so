local pMeta = FindMetaTable("Player")
function pMeta:canAfford(amount)
    if not amount or self.DarkRPUnInitialized then return false end
    return math.floor(amount) >= 0 and (self:getDarkRPVar("money") or 0) - math.ceil(amount) >= 0
end
