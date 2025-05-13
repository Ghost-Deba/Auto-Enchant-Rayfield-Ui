-- Load Rayfield safely
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Create main window
local Window = Rayfield:CreateWindow({
    Name = "Auto Enchant Pro",
    LoadingTitle = "جار التحميل...",
    LoadingSubtitle = "أداة الإنشانت التلقائي",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AutoEnchantConfig",
        FileName = "Settings"
    }
})

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

-- حالة التشغيل الحالية
local current = {
    selectedEnchant = enchants[1],
    selectedPickaxe = "Iron Pickaxe",
    pickaxeArgs = pickaxes["Iron Pickaxe"],
    isRunning = false,
    activeThread = nil
}

-- إنشاء واجهة المستخدم
local mainTab = Window:CreateTab("التحكم الرئيسي", 4483362458)

-- قائمة الإنشانتات
mainTab:CreateDropdown({
    Name = "اختر الإنشانت المطلوب",
    Options = enchants,
    CurrentOption = current.selectedEnchant,
    Callback = function(option)
        current.selectedEnchant = option
        Rayfield:Notify({
            Title = "تم التحديد",
            Content = "الإنشانت: "..option,
            Duration = 2
        })
    end
})

-- قائمة البيكاكس
mainTab:CreateDropdown({
    Name = "اختر البيكاكس",
    Options = {"Iron Pickaxe", "Gold Pickaxe", "Diamond Pickaxe", "Gem Pickaxe", "God Pickaxe", 
              "Grassy Pickaxe", "Ice Pickaxe", "Void Pickaxe", "Hellfire Pickaxe", "Pirate's Pickaxe",
              "Coral Pickaxe", "Sharkee Pick", "Lava Pickaxe"},
    CurrentOption = current.selectedPickaxe,
    Callback = function(option)
        current.selectedPickaxe = option
        current.pickaxeArgs = pickaxes[option] or {1, 1}
        Rayfield:Notify({
            Title = "تم التحديد",
            Content = "البيكاكس: "..option,
            Duration = 2
        })
    end
})

-- زر التشغيل التلقائي (الإصلاح الرئيسي هنا)
mainTab:CreateToggle({
    Name = "تفعيل الإنشانت التلقائي",
    CurrentValue = false,
    Callback = function(isActive)
        if isActive then
            -- إيقاف أي عملية سابقة إن وجدت
            if current.activeThread then
                coroutine.close(current.activeThread)
            end
            
            -- بدء العملية الجديدة
            current.isRunning = true
            current.activeThread = coroutine.create(function()
                while current.isRunning do
                    local success, currentEnchant = pcall(function()
                        return game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Enchant.Content.Slots["1"].EnchantName.ContentText
                    end)
                    
                    if success and currentEnchant == current.selectedEnchant then
                        current.isRunning = false
                        Rayfield:Notify({
                            Title = "تم الإكمال!",
                            Content = "تم الحصول على: "..current.selectedEnchant,
                            Duration = 5
                        })
                        break
                    else
                        -- تنفيذ الإنشانت
                        pcall(function()
                            game:GetService("ReplicatedStorage").Remotes.Enchant:FireServer(unpack(current.pickaxeArgs))
                        end)
                        task.wait(0.5)
                    end
                end
            end)
            
            coroutine.resume(current.activeThread)
            Rayfield:Notify({
                Title = "بدأ التشغيل",
                Content = "جاري البحث عن: "..current.selectedEnchant,
                Duration = 3
            })
        else
            -- إيقاف العملية
            current.isRunning = false
            if current.activeThread then
                coroutine.close(current.activeThread)
                current.activeThread = nil
            end
            Rayfield:Notify({
                Title = "تم الإيقاف",
                Content = "توقف الإنشانت التلقائي",
                Duration = 2
            })
        end
    end
})

-- إشعار البدء
Rayfield:Notify({
    Title = "جاهز للاستخدام",
    Content = "اختر الإعدادات ثم اضغط على التشغيل",
    Duration = 5
})
