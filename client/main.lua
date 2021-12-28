
ESX, data, DB = nil, {}, {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

apiCrypto = function()
    local main = RageUI.CreateMenu(('%s'):format(config.label.MENU_NAME), ("%s"):format(config.label.MENU_NAME))
    local myWallet = RageUI.CreateSubMenu(main, ('%s'):format(config.label.MENU_NAME), ("%s"):format(config.label.MENU_DESC_WALLET))
    local sub = RageUI.CreateSubMenu(myWallet, ('%s'):format(config.label.MENU_NAME), ("%s"):format(config.label.MENU_DESC_WALLET))
    local crypto = RageUI.CreateSubMenu(main, ('%s'):format(config.label.MENU_NAME), ("%s"):format(config.label.MENU_DESC_INFO_CRYPTO))

    RageUI.Visible(main, not RageUI.Visible(main)) 
    while main do
        Citizen.Wait(0)

        RageUI.IsVisible(main, function()
            RageUI.Separator(config.label.MENU_SEP_GESTION)
            RageUI.Button(config.label.MENU_DESC_WALLET, nil, {RightLabel = ">"}, true, {}, myWallet)
            if countTable(data) > 0 then
                RageUI.Separator(config.label.MENU_SEP_ALL_CRYPTO)
                for _, v in pairs(data) do 
                    RageUI.Button(v.name, nil, {RightLabel = ("%s ~g~$~s~ >"):format(customGroupDigits(v.price))}, true, {}, crypto)
                end
            else
                RageUI.Separator("")
                RageUI.Separator(config.label.MENU_SEP_NO_CRYPTO)
                RageUI.Separator("")
            end
        end)

        RageUI.IsVisible(myWallet, function()                 
            if countTable(DB) > 0 then
                for _, v in pairs(DB) do
                    RageUI.Button(("[~o~%s~s~] %s"):format(v.id, v.currency), nil, {RightLabel = ("~o~%s~s~ >"):format(v.numberOfCrypto)}, true, {
                        onSelected = function()
                            id = v.id
                            currency = v.currency
                            value = customGroupDigits(v.amountInvested)
                            benef = customGroupDigits(v.profit)
                            total = customGroupDigits(v.total)
                            date = v.dateOfPurchase 
                            buy = customGroupDigits(v.purchasePrice)
                            number = v.numberOfCrypto
                        end
                    }, sub)
                end
            else
                RageUI.Separator("")
                RageUI.Separator(config.label.MENU_SEP_NO_CRYPTO)
                RageUI.Separator("")
            end
        end)

        RageUI.IsVisible(crypto, function()
            for _, v in pairs(data) do             
                RageUI.Separator(config.label.MENU_SEP_RECAP)
                RageUI.Separator(config.label.MENU_SEP_LINE)
                RageUI.Button("Nom :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = v.name}, true, {})
                RageUI.Button("Prix :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = ("%s ~g~$~s~"):format(customGroupDigits(v.price))}, true, {})
                RageUI.Button("Devise :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = v.udt}, true, {})
                RageUI.Separator(config.label.MENU_SEP_LINE)
                RageUI.Button(("Acheter du ~o~%s~s~"):format(v.name), nil, {RightLabel = "~y~>>"}, true, {
                    onSelected = function()
                        local qty = showbox("Combien de ~g~$~s~ voulez-vous investir ?", "", 50, true)
                        if qty == nil then
                            RageUI.Notif("Quantité invalide")
                        else
                            TriggerServerEvent("buyCrypto", qty, v.name)
                            RageUI.GoBack()
                        end
                    end
                })
            end
        end)

        RageUI.IsVisible(sub, function()
            RageUI.Separator(config.label.MENU_SEP_RECAP)
            RageUI.Separator(config.label.MENU_SEP_LINE)
            RageUI.Button("Nom de la crypto :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = currency}, true, {})
            RageUI.Button("Montant investis :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = ("%s ~g~$~s~"):format(value)}, true, {})
            RageUI.Button("Bénéfice :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = ("%s ~g~$~s~"):format(benef)}, true, {})
            RageUI.Button("Total :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = ("%s ~g~$~s~"):format(total)}, true, {})
            RageUI.Button("Date :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = date}, true, {})
            RageUI.Button("Prix du BTC à l'achat :", nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = ("%s ~g~$~s~"):format(buy)}, true, {})
            RageUI.Button(("Nombre de %s :"):format(currency), nil, {LeftBadge = RageUI.BadgeStyle.Star, RightLabel = number}, true, {})
            RageUI.Separator(config.label.MENU_SEP_LINE)
            RageUI.Button(("Vendre du ~o~%s~s~"):format(currency), nil, {RightLabel = "~y~>>"}, true, {
                onSelected = function()
                    local qty = showbox("Combien de "..currency.." voulez-vous vendre ?", "", 50, true)
                    if qty == nil then
                        RageUI.Notif("Quantité invalide")
                    else
                        TriggerServerEvent("sellCrypto", id, qty)
                    end
                end
            })
            RageUI.Button(("~r~Vendre ~s~tout le ~y~%s~s~"):format(currency), nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, {
                onSelected = function()
                    TriggerServerEvent("sellAllCrypto", id, number)
                    RageUI.GoBack()
                end
            })
        end)

        if not RageUI.Visible(main) and not RageUI.Visible(sub) and not RageUI.Visible(myWallet) and not RageUI.Visible(crypto) then
            main = RMenu:DeleteType('main', true)
            sub = RMenu:DeleteType('sub', true)
            myWallet = RMenu:DeleteType('myWallet', true)
            crypto = RMenu:DeleteType('crypto', true)
        end
    end
end

Keys.Register("F3", "F3", "api", function()
    refreshAPI()
    RefreshPlayerData()
    apiCrypto()
end)

refreshAPI = function()
    ESX.TriggerServerCallback('getAPI', function(showDataAPI)
        data = showDataAPI
    end)
end

RefreshPlayerData = function()
    ESX.TriggerServerCallback('getDatabase', function(showDataDB)
        DB = showDataDB
    end)
end