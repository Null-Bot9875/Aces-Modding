local CARD_ID = 910001
local CORE_POOL_ID = 10003
local CARD_POOL_ENTRY_COPIES = 10

local rows = {}

for _ = 1, CARD_POOL_ENTRY_COPIES do
    rows[#rows + 1] = {
        cardId = CARD_ID,
        baseId = 501,
        poolId = CORE_POOL_ID,
        minBaseLevel = 1,
        maxBaseLevel = 10,
        limitActIds = { -1 },
    }
end

return {
    installKey = "poolId",
    installValue = CORE_POOL_ID,
    operation = "append",
    rows = rows,
}
