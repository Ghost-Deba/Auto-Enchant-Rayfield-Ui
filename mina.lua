-- Load Rayfield with better error handling
local Rayfield = nil
local function loadRayfield()
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
    end)
    if success then return result end
    warn("فشل تحميل مكتبة Rayfield: "..tostring(result))
    return nil
end

Rayfield = loadRayfield()
if not Rayfield then return end

-- Create main window safely
local Window = nil
local function createWindow()
    local success, result = pcall(function()
        return Rayfield:CreateWindow({
            Name = "Auto Enchant",
            LoadingTitle = "جار التحميل...",
            LoadingSubtitle = "أوتو إنشانت",
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "AutoEnchantConfig",
                FileName = "Config"
            }
        })
    end)
    if success then return result end
    warn("فشل إنشاء النافذة: "..tostring(result))
    return nil
end

Window = createWindow()
if not Window then return end

-- البيانات الأساسية
local enchants = {
    "Magic Ores", "Incredible Damage", "Deadly Damage++", "Deadly Damage", "More Damage", "Light Damage",
    "Incredible Luck", "Mighty Luck++", "Mighty Luck", "Considerable Luck", "Abnormal Speed"
}

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

-- المتغيرات الحالية
local current = {
    enchant = enchants[1],
    pickaxe = "Iron Pickaxe",
    pickaxeArgs = pickaxes["Iron Pickaxe"],
    running = false
}

-- إنشاء الواجهة
local tab = Window:CreateTab("الإنشانت التلقائي", 4483362458)

-- قائمة الإنشانتات
local function createEnchantDropdown()
    local success, _ = pcall(function()
        tab:CreateDropdown({
            Name = "اختر الإنشانت",
            Options = enchants,
            CurrentOption = current.enchant,
            Callback = function(option)
                current.enchant = option
                Rayfield:Notify({
                    Title = "تم التحديد",
                    Content = "إنشانت: "..option,
                    Duration = 2
                })
            end
        })
    end)
end

-- قائمة البيكاكس (إصلاح)
local function createPickaxeDropdown()
    local pickaxeNames = {}
    for name, _ in pairs(pickaxes) do
        table.insert(pickaxeNames, name)
    end

    local success, _ = pcall(function()
        tab:CreateDropdown({
            Name = "اختر البيكاكس",
            Options = pickaxeNames,
            CurrentOption = current.pickaxe,
            Callback = function(option)
                current.pickaxe = option
                current.pickaxeArgs = pickaxes[option] or {1, 1}
                Rayfield:Notify({
                    Title = "تم التحديد",
                    Content = "بيكاكس: "..option,
                    Duration = 2
                })
            end
        })
    end)
end

-- زر الإنشانت التلقائي
local function createAutoToggle()
    pcall(function()
        tab:CreateToggle({
            Name = "الإنشانت التلقائي",
            CurrentValue = current.running,
            Callback = function(value)
                current.running = value
                if value then
                    Rayfield:Notify({
                        Title = "بدأ التشغيل",
                        Content = "جاري البحث عن: "..current.enchant,
                        Duration = 3
                    })
                    startAutoEnchant()
                else
                    Rayfield:Notify({
                        Title = "تم الإيقاف",
                        Content = "توقف الإنشانت التلقائي",
                        Duration = 2
                    })
                end
            end
        })
    end)
end

-- دالة لجلب الإنشانت الحالي
local function getCurrentEnchant()
    local success, result = pcall(function()
        local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        local enchantName = gui:FindFirstChild("ScreenGui")?
            :FindFirstChild("Enchant")?
            :FindFirstChild("Content")?
            :FindFirstChild("Slots")?
            :FindFirstChild("1")?
            :FindFirstChild("EnchantName")
        return enchantName and enchantName.ContentText and enchantName.ContentText:lower():gsub("%s+", "")
    end)
    return success and result or nil
end

-- تنفيذ الإنشانت
local function performEnchant()
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local enchantRemote = remotes and remotes:FindFirstChild("Enchant")
        if enchantRemote and typeof(current.pickaxeArgs) == "table" then
            enchantRemote:FireServer(unpack(current.pickaxeArgs))
        end
    end)
end

-- تشغيل الإنشانت التلقائي
function startAutoEnchant()
    spawn(function()
        while current.running do
            local found = getCurrentEnchant()
            if found and found == current.enchant:lower():gsub("%s+", "") then
                current.running = false
                Rayfield:Notify({
                    Title = "تم العثور عليه!",
                    Content = "تم الحصول على: "..current.enchant,
                    Duration = 5
                })
                break
            else
                performEnchant()
            end
            task.wait(0.5)
        end
    end)
end

-- إنشاء العناصر
createEnchantDropdown()
createPickaxeDropdown()
createAutoToggle()

-- إشعار جاهزية
Rayfield:Notify({
    Title = "جاهز للاستخدام",
    Content = "اختر الإعدادات ثم اضغط على التشغيل",
    Duration = 5
})
