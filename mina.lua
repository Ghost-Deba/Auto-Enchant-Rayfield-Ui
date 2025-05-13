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

-- إنشاء واجهة المستخدم
local tab = Window:CreateTab("الإنشانت التلقائي", 4483362458)

-- قائمة الإنشانتات
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

-- قائمة البيكاكس
local function createPickaxeDropdown()
    local success, dropdown = pcall(function()
        return tab:CreateDropdown({
            Name = "اختر البيكاكس",
            Options = table.pack(table.unpack(enchants)),
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

-- زر التشغيل التلقائي
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

-- الحصول على الإنشانت الحالي
local function getCurrentEnchant()
    local success, result = pcall(function()
        local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return nil end

        local screenGui = gui:FindFirstChild("ScreenGui")
        if not screenGui then return nil end

        local enchant = screenGui:FindFirstChild("Enchant")
        if not enchant then return nil end

        local content = enchant:FindFirstChild("Content")
        if not content then return nil end

        local slots = content:FindFirstChild("Slots")
        if not slots then return nil end

        local slot1 = slots:FindFirstChild("1")
        if not slot1 then return nil end

        local name = slot1:FindFirstChild("EnchantName")
        if not name then return nil end

        return name.ContentText
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

-- الوظيفة الرئيسية للإنشانت التلقائي
function startAutoEnchant()
    spawn(function()
        while current.running do
            local found = getCurrentEnchant()
            if found and found == current.enchant then
                current.running = false
                pcall(function()
                    Rayfield:Notify({
                        Title = "تم العثور عليه!",
                        Content = "تم الحصول على: "..current.enchant,
                        Duration = 5
                    })
                end)
                break
            elseif found then
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
pcall(function()
    Rayfield:Notify({
        Title = "جاهز للاستخدام",
        Content = "اختر الإعدادات ثم اضغط على التشغيل",
        Duration = 5
    })
end)
