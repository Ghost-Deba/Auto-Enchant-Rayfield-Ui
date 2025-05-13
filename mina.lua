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

-- إنشاء واجهة المستخدم
local tab = Window:CreateTab("الإنشانت التلقائي", 4483362458)

-- قائمة الإنشانتات (مع معالجة الأخطاء)
local function createEnchantDropdown()
    local success, dropdown = pcall(function()
        return tab:CreateDropdown({
            Name = "اختر الإنشانت",
            Options = enchants,
            CurrentOption = current.enchant,
            Callback = function(option)
                current.enchant = option
                pcall(function()
                    Rayfield:Notify({
                        Title = "تم التحديد",
                        Content = "إنشانت: "..option,
                        Duration = 2
                    })
                end)
            end
        })
    end)
    if not success then
        warn("خطأ في إنشاء قائمة الإنشانت: "..tostring(dropdown))
    end
end

-- قائمة البيكاكس (مع معالجة الأخطاء)
local function createPickaxeDropdown()
    local success, dropdown = pcall(function()
        return tab:CreateDropdown({
            Name = "اختر البيكاكس",
            Options = {"Iron Pickaxe", "Gold Pickaxe", "Diamond Pickaxe", "Gem Pickaxe", "God Pickaxe", 
                      "Grassy Pickaxe", "Ice Pickaxe", "Void Pickaxe", "Hellfire Pickaxe", "Pirate's Pickaxe",
                      "Coral Pickaxe", "Sharkee Pick", "Lava Pickaxe"},
            CurrentOption = current.pickaxe,
            Callback = function(option)
                current.pickaxe = option
                current.pickaxeArgs = pickaxes[option] or {1, 1}
                pcall(function()
                    Rayfield:Notify({
                        Title = "تم التحديد",
                        Content = "بيكاكس: "..option,
                        Duration = 2
                    })
                end)
            end
        })
    end)
    if not success then
        warn("خطأ في إنشاء قائمة البيكاكس: "..tostring(dropdown))
    end
end

-- زر التشغيل التلقائي (مع معالجة الأخطاء)
local function createAutoToggle()
    local success, toggle = pcall(function()
        return tab:CreateToggle({
            Name = "الإنشانت التلقائي",
            CurrentValue = current.running,
            Callback = function(value)
                current.running = value
                if value then
                    pcall(function()
                        Rayfield:Notify({
                            Title = "بدأ التشغيل",
                            Content = "جاري البحث عن: "..current.enchant,
                            Duration = 3
                        })
                    end)
                    startAutoEnchant()
                else
                    pcall(function()
                        Rayfield:Notify({
                            Title = "تم الإيقاف",
                            Content = "توقف الإنشانت التلقائي",
                            Duration = 2
                        })
                    end)
                end
            end
        })
    end)
    if not success then
        warn("خطأ في إنشاء زر التشغيل: "..tostring(toggle))
    end
end

-- الدوال المساعدة
local function getCurrentEnchant()
    local success, result = pcall(function()
        local gui = game:GetService("Players").LocalPlayer.PlayerGui
        local screenGui = gui and gui:FindFirstChild("ScreenGui")
        local enchant = screenGui and screenGui:FindFirstChild("Enchant")
        local content = enchant and enchant:FindFirstChild("Content")
        local slots = content and content:FindFirstChild("Slots")
        local slot1 = slots and slots:FindFirstChild("1")
        local name = slot1 and slot1:FindFirstChild("EnchantName")
        return name and name.ContentText
    end)
    return success and result or nil
end

local function performEnchant()
    pcall(function()
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local enchantRemote = remotes and remotes:FindFirstChild("Enchant")
        if enchantRemote then
            enchantRemote:FireServer(unpack(current.pickaxeArgs))
        end
    end)
end

-- الوظيفة الرئيسية
local function startAutoEnchant()
    spawn(function()
        while current.running do
            local found = getCurrentEnchant()
            if found == current.enchant then
                current.running = false
                pcall(function()
                    Rayfield:Notify({
                        Title = "تم العثور عليه!",
                        Content = "تم الحصول على: "..current.enchant,
                        Duration = 5
                    })
                end)
                break
            else
                performEnchant()
                task.wait(0.5)
            end
        end
    end)
end

-- إنشاء العناصر
createEnchantDropdown()
createPickaxeDropdown()
createAutoToggle()

-- الإشعار الأولي
pcall(function()
    Rayfield:Notify({
        Title = "جاهز للاستخدام",
        Content = "اختر الإعدادات ثم اضغط على التشغيل",
        Duration = 5
    })
end)
