local ESX = exports.es_extended:getSharedObject()

ESX.RegisterServerCallback('getAPI', function(source, cb)
    local showDataAPI = {}
    for k, v in pairs(config.api) do
        if v == "" then
            print("API not found")
            return
        else
            PerformHttpRequest(v, function(errorCode, resultData, resultHeaders)
                local data = json.decode(resultData)
                nom = data.data.base
                prix = data.data.amount
                devise = data.data.currency
                table.insert(showDataAPI, {
                    name = nom,
                    price = prix,
                    udt = devise
                })
                cb(showDataAPI)
            end)
        end
    end
end)

ESX.RegisterServerCallback('getDatabase', function(source, cb)
    Wait(1000)
    local showDataDB = {}
    local identifier = getIdentifiers(source)
    local query = 'SELECT * FROM crypto WHERE (owner = @owner)'
    MySQL.Async.fetchAll(query, {
        ['@owner'] = identifier
    }, function(result)
        for i = 1, #result, 1 do
            table.insert(showDataDB, {
                id = result[i].id,
                owner = result[i].owner,
                currency = result[i].currency,
                numberOfCrypto = result[i].numberOfCrypto,
                amountInvested = result[i].amountInvested,
                profit = round(result[i].numberOfCrypto * prix - result[i].amountInvested),
                total = round(result[i].numberOfCrypto * prix),
                dateOfPurchase = result[i].dateOfPurchase,
                purchasePrice = result[i].purchasePrice
            })
        end
    cb(showDataDB)
    end)
end)

RegisterNetEvent("sellCrypto")
AddEventHandler("sellCrypto", function(id, quantity)
    _quantity = tonumber(quantity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = getIdentifiers(_source)
    if _quantity == nil or _quantity == 0 then
        TriggerClientEvent('esx:showNotification', _source, "~r~Error ~s~: quantité invalide")
        return
    else
        local _reward = round(prix * _quantity)
        local _querySelect = 'SELECT * FROM crypto WHERE id = @id'
        MySQL.Async.fetchAll(_querySelect, {
            ['@id'] = id,
        }, function(result)
            for i = 1, #result, 1 do
                if tonumber(result[i].numberOfCrypto) >= _quantity then
                    local _remove = tonumber(result[i].numberOfCrypto) - _quantity
                    local _queryUpdate = 'UPDATE crypto SET numberOfCrypto = @b WHERE id = @a'
                    MySQL.Async.execute(_queryUpdate, {
                        ['@a'] = id,
                        ['@b'] = _remove
                    }, function (result)
                        xPlayer.addAccountMoney('money', _reward)
                        TriggerClientEvent('esx:showNotification', _source, ("Vous avez vendu %s %s pour : %s ~g~$~s~"):format(_quantity, nom, _reward))
                    end)
                else
                    TriggerClientEvent('esx:showNotification', _source, "~r~Error ~s~: Tu n'as pas tout cet crypto")
                end
            end
        end)
    end
end)

RegisterNetEvent("sellAllCrypto")
AddEventHandler("sellAllCrypto", function(id, quantity)
    _quantity = tonumber(quantity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = getIdentifiers(_source)
    if _quantity == nil or _quantity == 0 then
        TriggerClientEvent('esx:showNotification', _source, "~r~Error ~s~: quantité invalide")
        return
    else
        local _reward = round(prix * _quantity)
        local _query = 'DELETE FROM crypto WHERE id = @id'
        MySQL.Async.execute(_query, {
            ['@id'] =  id
        }, function (result)
            xPlayer.addAccountMoney('money', _reward)
            TriggerClientEvent('esx:showNotification', _source, ("Vous avez vendu tout votre %s pour : %s ~g~$~s~"):format(nom, _reward))
        end)
    end
end)

RegisterNetEvent("buyCrypto")
AddEventHandler("buyCrypto", function(quantity, name)
    _quantity = tonumber(quantity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = getIdentifiers(_source)
    if _quantity == nil or _quantity == 0 then
        TriggerClientEvent('esx:showNotification', _source, "~r~Error ~s~: quantité invalide")
        return
    end
    if xPlayer.getAccount('money').money >= _quantity then
        local _calcul = _quantity / prix
        MySQL.Async.execute('INSERT INTO crypto (owner, currency, numberOfCrypto, amountInvested, dateOfPurchase, purchasePrice) VALUES (@a, @b, @c, @d, @e, @f)', {
            ['@a'] = identifier,
            ['@b'] = name,
            ['@c'] = _calcul,
            ['@d'] = _quantity,
            ['@e'] = getLocalTime(),
            ['@f'] = prix
        }, function (result)
            xPlayer.removeAccountMoney('money', _quantity)
            TriggerClientEvent('esx:showNotification', _source, ("Vous avez ~g~acheter~s~ %s %s pour : %s ~g~$~s~"):format(_calcul, nom, _quantity))
        end)
    else 
        TriggerClientEvent('esx:showNotification', _source, "~r~Error ~s~: Tu n'as pas assez d'argent")
    end
end)

getLocalTime = function()
    local myDate = os.date("%d/%m/%Y", os.time())
    local myTime = os.date("%H:%M:%S", os.time())
    return myDate.. " " ..myTime
end

round = function(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

getIdentifiers = function(_src)
    local xPlayer = ESX.GetPlayerFromId(_src)
    local identifier = xPlayer.identifier
    return identifier
end