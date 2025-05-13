local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Enchant",
    LoadingTitle = "Auto Enchant Loader",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AutoEnchantConfig",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    }
})

-- Available enchants list
local enchants = {
    "Magic Ores",
    "Incredible Damage",
    "Deadly Damage++",
    "Deadly Damage",
    "More Damage",
    "Light Damage",
    "Incredible Luck",
    "Mighty Luck++",
    "Mighty Luck",
    "Considerable Luck",
    "Abnormal Speed"
}

-- Pickaxes list with their settings
local pickaxes = {
    ["Iron Pickaxe"] = {1, 1},
    ["Gold Pickaxe"] = {129, 1},
    ["Diamond Pickaxe"] = {128, 1},
    ["Gem Pickaxe"] = {4, 1},
    ["God Pickaxe"] = {130, 1},
    ["Grassy Pickaxe"] = {132, 1},
    ["Ice Pickaxe"] = {131, 1},
    ["Void Pickaxe"] = {6, 1},
    ["Hellfire Pickaxe"] = {133, 1},
    ["Pirate's Pickaxe"] = {8, 1},
    ["Coral Pickaxe"] = {127, 1},
    ["Sharkee Pick"] = {9, 1},
    ["Lava Pickaxe"] = {76, 1}
}

-- Variables
local selectedEnchant = ""
local selectedPickaxeName = "Iron Pickaxe"
local selectedPickaxeArgs = {1, 1}
local autoEnchanting = false

-- Create UI elements
local EnchantTab = Window:CreateTab("Auto Enchant", 4483362458)

-- Dropdown for enchants (Fixed)
local EnchantDropdown = EnchantTab:CreateDropdown({
    Name = "Select Enchant",
    Options = enchants,
    CurrentOption = "Magic Ores",
    Flag = "EnchantDropdown",
    Callback = function(Option)
        selectedEnchant = Option
        Rayfield:Notify({
            Title = "Enchant Selected",
            Content = "Selected: " .. tostring(Option),
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Dropdown for pickaxes (Fixed)
local PickaxeDropdown = EnchantTab:CreateDropdown({
    Name = "Select Pickaxe",
    Options = {"Iron Pickaxe", "Gold Pickaxe", "Diamond Pickaxe", "Gem Pickaxe", "God Pickaxe", 
               "Grassy Pickaxe", "Ice Pickaxe", "Void Pickaxe", "Hellfire Pickaxe", "Pirate's Pickaxe",
               "Coral Pickaxe", "Sharkee Pick", "Lava Pickaxe"},
    CurrentOption = "Iron Pickaxe",
    Flag = "PickaxeDropdown",
    Callback = function(Option)
        selectedPickaxeName = Option
        selectedPickaxeArgs = pickaxes[Option]
        Rayfield:Notify({
            Title = "Pickaxe Selected",
            Content = "Selected: " .. tostring(Option),
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Auto enchant toggle (Fixed)
local AutoEnchantToggle = EnchantTab:CreateToggle({
    Name = "Auto Enchant",
    CurrentValue = false,
    Flag = "AutoEnchantToggle",
    Callback = function(Value)
        autoEnchanting = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Enchant Started",
                Content = "Enchanting until: " .. tostring(selectedEnchant),
                Duration = 3,
                Image = 4483362458
            })
            startAutoEnchant()
        else
            Rayfield:Notify({
                Title = "Auto Enchant Stopped",
                Content = "Stopped auto enchanting",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- Function to check current enchant
local function getCurrentEnchant()
    local success, result = pcall(function()
        return game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Enchant.Content.Slots["1"].EnchantName.ContentText
    end)
    
    if success then
        return result
    else
        return nil
    end
end

-- Function to perform enchant
local function performEnchant()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Enchant"):FireServer(unpack(selectedPickaxeArgs))
end

-- Main auto enchant function
local function startAutoEnchant()
    spawn(function()
        while autoEnchanting and selectedEnchant ~= "" do
            local currentEnchant = getCurrentEnchant()
            
            if currentEnchant == selectedEnchant then
                autoEnchanting = false
                AutoEnchantToggle:Set(false)
                Rayfield:Notify({
                    Title = "Enchant Found!",
                    Content = "Successfully got: " .. tostring(selectedEnchant),
                    Duration = 5,
                    Image = 4483362458
                })
                break
            else
                performEnchant()
                wait(0.5) -- Delay to prevent spamming
            end
        end
    end)
end

-- Initialize with default values
selectedEnchant = enchants[1]
selectedPickaxeName = "Iron Pickaxe"
selectedPickaxeArgs = pickaxes["Iron Pickaxe"]

Rayfield:Notify({
    Title = "Auto Enchant Loaded",
    Content = "Select your options and start enchanting!",
    Duration = 5,
    Image = 4483362458
})
