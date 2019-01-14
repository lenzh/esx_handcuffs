ESX               = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

----
ESX.RegisterUsableItem('handcuffs', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerClientEvent('esx_handcuffs:openmenu', source)
	--TriggerClientEvent('esx_handcuffs:cuffcheck', source)
end)

RegisterServerEvent('esx_handcuffs:cuffing')
AddEventHandler('esx_handcuffs:cuffing', function(source)
  TriggerClientEvent('esx_handcuffs:cuff', source)
end)

----
ESX.RegisterUsableItem('key', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('key', 1)

	TriggerClientEvent('esx_handcuffs:unlockingcuffs', source)
end)

RegisterServerEvent('esx_handcuffs:unlocking')
AddEventHandler('esx_handcuffs:unlocking', function(source)
  TriggerClientEvent('esx_handcuffs:unlockingcuffs', source)
end)
---


RegisterServerEvent('esx_handcuffs:drag')
AddEventHandler('esx_handcuffs:drag', function(target)
  local _source = source
  TriggerClientEvent('esx_handcuffs:drag', target, _source)
end)

RegisterServerEvent('esx_handcuffs:putInVehicle')
AddEventHandler('esx_handcuffs:putInVehicle', function(target)
  TriggerClientEvent('esx_handcuffs:putInVehicle', target)
end)

RegisterServerEvent('esx_handcuffs:OutVehicle')
AddEventHandler('esx_handcuffs:OutVehicle', function(target)
    TriggerClientEvent('esx_handcuffs:OutVehicle', target)
end)
