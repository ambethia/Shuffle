local ADDON, NS = ...

local frame = CreateFrame("FRAME", ADDON .. "Frame")

local MIN_FREE_SLOTS = 4
local numFreeSlots = 0
local pantsCount = 0
local isSellMode = true

local function CraftOrVendor()
    local isTradeSkillReady = C_TradeSkillUI.IsTradeSkillReady()
    if isSellMode then
        if MerchantFrame:IsVisible() then
            if pantsCount > 0 then
                print("Selling")
                for bagID = 0, NUM_BAG_SLOTS do
                    for slotID = 1, GetContainerNumSlots(bagID) do
                        if GetContainerItemID(bagID, slotID) == 126991 then -- Silkweave Pantaloons
                            C_Timer.After(0.1, function()
                                UseContainerItem(bagID, slotID);
                            end)
                        end
                    end
                end
            else
                isSellMode = false;
            end
        else
            PlaySound(7355);
            print("Open a Merchant Frame.");
        end
    elseif isTradeSkillReady then
        if numFreeSlots >= MIN_FREE_SLOTS then
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(208353); -- Silkweave Pantaloons (Rank 3)
            if recipeInfo.numAvailable > 0 then
                local isCastingTradeSkill = select(6, UnitCastingInfo("player"))
                if not isCastingTradeSkill then
                    C_TradeSkillUI.CraftRecipe(208353, recipeInfo.numAvailable)
                end
            else
                local numRunicCatgut = GetItemCount(127037);
                local numSharpSpritethorn = GetItemCount(127681);
                if numRunicCatgut < 200 or numSharpSpritethorn < 100 then
                    if MerchantFrame:IsVisible() then
                        for index = 1,  GetMerchantNumItems() do
                            local itemName = GetMerchantItemInfo(index)
                            if itemName == "Runic Catgut" and numRunicCatgut < 200 then
                                print("Buying ".. 200 - numRunicCatgut .. ' ' .. itemName)
                                BuyMerchantItem(index, 200 - numRunicCatgut)
                            end
                            if itemName == "Sharp Spritethorn" and numSharpSpritethorn < 200 then
                                print("Buying ".. 200 - numSharpSpritethorn .. ' ' .. itemName)
                                BuyMerchantItem(index, 100 - numSharpSpritethorn)
                            end
                        end
                    else
                        PlaySound(7355);
                        print("Open a Merchant Frame.");
                    end
                else
                    PlaySound(7355);
                    print("No Cloth.");
                    isSellMode = true;
                end
            end
        else
            print("Bags Full.")
            isSellMode = true
        end
    else
        C_TradeSkillUI.OpenTradeSkill(197); -- Tailoring
    end
end

frame:SetScript("OnEvent", function(_, event, ...)
    if event == 'BAG_UPDATE' then
        numFreeSlots = 0
        pantsCount = GetItemCount(126991); -- Silkweave Pantaloons
        for bagID = 0, NUM_BAG_SLOTS do
            numFreeSlots = numFreeSlots + GetContainerNumFreeSlots(bagID);
        end
    end
end )
frame:RegisterEvent("BAG_UPDATE")

SLASH_SHUFFLE1 = "/shuffle"
SlashCmdList["SHUFFLE"] = function(msg)
    CraftOrVendor()
end