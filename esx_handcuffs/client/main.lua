-- ESX
ESX               = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

-- Locals

local cuffed = false
local dict = "mp_arresting"
local anim = "idle"
local flags = 49
local ped = PlayerPedId()
local changed = false
local prevMaleVariation = 0
local prevFemaleVariation = 0
local femaleHash = GetHashKey("mp_f_freemode_01")
local maleHash = GetHashKey("mp_m_freemode_01")
local IsLockpicking    = false
local IsDragged = false


RegisterNetEvent('esx_handcuffs:cuff')
AddEventHandler('esx_handcuffs:cuff', function()
    ped = GetPlayerPed(-1)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end

        if GetEntityModel(ped) == femaleHash then
            prevFemaleVariation = GetPedDrawableVariation(ped, 7)
            SetPedComponentVariation(ped, 7, 25, 0, 0)
        elseif GetEntityModel(ped) == maleHash then
            prevMaleVariation = GetPedDrawableVariation(ped, 7)
            SetPedComponentVariation(ped, 7, 41, 0, 0)
        end

        SetEnableHandcuffs(ped, true)
        TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)

    cuffed = not cuffed
    changed = true
end)
--- Uncufing
RegisterNetEvent('esx_handcuffs:uncuff')
AddEventHandler('esx_handcuffs:uncuff', function()
    ped = GetPlayerPed(-1)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end

        ClearPedTasks(ped)
        SetEnableHandcuffs(ped, false)
        UncuffPed(ped)

        if GetEntityModel(ped) == femaleHash then -- mp female
            SetPedComponentVariation(ped, 7, prevFemaleVariation, 0, 0)
        elseif GetEntityModel(ped) == maleHash then -- mp male
            SetPedComponentVariation(ped, 7, prevMaleVariation, 0, 0)
        end

    cuffed = not cuffed

    changed = true
end)

RegisterNetEvent('esx_handcuffs:cuffcheck')
AddEventHandler('esx_handcuffs:cuffcheck', function()
  local player, distance = ESX.Game.GetClosestPlayer()
  if distance ~= -1 and distance <= 3.0 then
  				  RequestAnimDict("amb@prop_human_bum_bin@idle_b")
				  TaskPlayAnim(ped,"amb@prop_human_bum_bin@idle_b","idle_d",100.0, 200.0, 0.3, 120, 0.2, 0, 0, 0, 130)
								ESX.ShowNotification('~g~You have used your handcuffs')
				Wait(4000)
		TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(player))
				ESX.ShowNotification('~r~Person Cuffed/UnCuffed')
  else
    ESX.ShowNotification('No players nearby')
	end
end)

RegisterNetEvent('esx_handcuffs:nyckelcheck')
AddEventHandler('esx_handcuffs:nyckelcheck', function()
	local player, distance = ESX.Game.GetClosestPlayer()
  if distance ~= -1 and distance <= 3.0 then
      TriggerServerEvent('esx_handcuffs:unlocking', GetPlayerServerId(player))
  else
    ESX.ShowNotification('No players nearby')
	end
end)

RegisterNetEvent('esx_handcuffs:unlockingcuffs')
AddEventHandler('esx_handcuffs:unlockingcuffs', function()
  local player, distance = ESX.Game.GetClosestPlayer()
	local ped = GetPlayerPed(-1)

	if IsLockpicking == false then
		ESX.UI.Menu.CloseAll()
		FreezeEntityPosition(player,  true)
		FreezeEntityPosition(ped,  true)

		TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true)

		IsLockpicking = true

		Wait(30000)

		IsLockpicking = false

		FreezeEntityPosition(player,  false)
		FreezeEntityPosition(ped,  false)

		ClearPedTasksImmediately(ped)

		TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(player))
		ESX.ShowNotification('Handcuffs unlocked')
	else
		ESX.ShowNotification('Your are already lockpicking handcuffs')
	end
end)

function OpenHandcuffsmenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'handcuff_actions',
    {
      title    = _U('handcuffmenu'),
      align    = 'bottom-right',
      elements = {
                    {label =  _U('search'),            value = 'body_search'},
                    {label =  _U('handcuff'),        value = 'handcuff'},
                    {label =  _U('drag'),            value = 'drag'},
                    {label =  _U('put_in_vehicle'),    value = 'put_in_vehicle'},
                    {label =  _U('out_the_vehicle'),    value = 'out_the_vehicle'}
            }
    },
    function(data, menu)

            local player, distance = ESX.Game.GetClosestPlayer()

            if distance ~= -1 and distance <= 3.0 then
              local action = data.current.value

                            if action == 'body_search' then
                                OpenStealMenu(player)
                            elseif action == 'handcuff' then
                                TriggerEvent('esx_handcuffs:cuffcheck', GetPlayerServerId(player))
                            elseif action == 'drag' then
                                TriggerServerEvent('esx_handcuffs:drag', GetPlayerServerId(player))
                            elseif action == 'put_in_vehicle' then
                                TriggerServerEvent('esx_handcuffs:putInVehicle', GetPlayerServerId(player))
                            elseif action == 'out_the_vehicle' then
                                TriggerServerEvent('esx_handcuffs:OutVehicle', GetPlayerServerId(player))
                            end

                        else
                            ESX.ShowNotification(_U('no_players_nearby'))
                        end

            end,
         function(data, menu)
          menu.close()
       end
      )
end


function OpenStealMenu(target, target_id)

    ESX.UI.Menu.CloseAll()

    ESX.TriggerServerCallback('esx_thief:getOtherPlayerData', function(data)

        local elements = {}

        if Config.EnableCash then
            table.insert(elements, {
                label      = '[' .. _U('cash') .. '] $' .. data.money,
                value      = 'money',
                type       = 'item_money',
                amount     = data.money,
            })
        end

        if Config.EnableBlackMoney then
            local blackMoney = 0
            for i=1, #data.accounts, 1 do
              if data.accounts[i].name == 'black_money' then
                blackMoney = data.accounts[i].money
              end
            end

            table.insert(elements, {
              label          = '[' .. _U('black_money') .. '] $' .. blackMoney,
              value          = 'black_money',
              type           = 'item_account',
              amount         = blackMoney,
            })
        end

        if Config.EnableInventory then
            table.insert(elements, {label = '--- ' .. _U('inventory') .. ' ---', value = nil})

            for i=1, #data.inventory, 1 do
              if data.inventory[i].count > 0 then
                table.insert(elements, {
                  label          = data.inventory[i].label .. ' x' .. data.inventory[i].count,
                  value          = data.inventory[i].name,
                  type           = 'item_standard',
                  amount         = data.inventory[i].count,
                })
              end
            end
        end


        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'steal_inventory',
        {
            title  = _U('target_inventory'),
            elements = elements,
            align = 'bottom-right'
        },
        function(data, menu)

            if data.current.value ~= nil then

                local itemType = data.current.type
                local itemName = data.current.value
                local amount   = data.current.amount
                local elements = {}
                table.insert(elements, {label = _U('steal'), action = "steal", itemType, itemName, amount})
                table.insert(elements, {label = _U('return'), action = "return"})
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'steal_inventory_item',
                    {
                        title = _U('action_choice'),
                        align = "bottom-right",
                        elements = elements
                    },
                    function(data2, menu2)

                        if data2.current.action == 'steal' then

                            if itemType == 'item_standard' then
                                ESX.UI.Menu.Open(
                                    'dialog', GetCurrentResourceName(), 'steal_inventory_item_standard',
                                    {
                                      title = _U('amount')
                                    },
                                    function(data3, menu3)
                                        local quantity = tonumber(data3.value)
                                        TriggerServerEvent('esx_thief:stealPlayerItem', GetPlayerServerId(target), itemType, itemName, quantity)
                                        OpenStealMenu(target)

                                        menu3.close()
                                        menu2.close()

                                    end,
                                    function(data3, menu3)
                                      menu3.close()
                                    end
                                  )

                            else
                                TriggerServerEvent('esx_thief:stealPlayerItem', GetPlayerServerId(target), itemType, itemName, amount)
                                OpenStealMenu(target)
                            end

                        elseif data2.current.action == 'return' then

                            ESX.UI.Menu.CloseAll()
                            OpenStealMenu(target)

                        end

                    end,
                    function(data2, menu2)
                        menu2.close()
                    end
                )

            end

        end,
        function(data, menu)
            menu.close()
        end
        )

    end, GetPlayerServerId(target))

end

RegisterNetEvent('esx_handcuffs:drag')
AddEventHandler('esx_handcuffs:drag', function(cop)
  TriggerServerEvent('esx:clientLog', 'starting dragging')
  IsDragged = not IsDragged

end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if IsHandcuffed then
      if IsDragged then
        local ped = GetPlayerPed(GetPlayerFromServerId(CopPed))
        local myped = GetPlayerPed(-1)
        AttachEntityToEntity(myped, ped, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
      else
        DetachEntity(GetPlayerPed(-1), true, false)
      end
    end
  end
end)

RegisterNetEvent('esx_handcuffs:putInVehicle')
AddEventHandler('esx_handcuffs:putInVehicle', function()

  local playerPed = GetPlayerPed(-1)
  local coords    = GetEntityCoords(playerPed)

  if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

    local vehicle = GetClosestVehicle(coords.x,  coords.y,  coords.z,  5.0,  0,  71)

    if DoesEntityExist(vehicle) then

      local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
      local freeSeat = nil

      for i=maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle,  i) then
          freeSeat = i
          break
        end
      end

      if freeSeat ~= nil then
        TaskWarpPedIntoVehicle(playerPed,  vehicle,  freeSeat)
      end

    end

  end

end)

RegisterNetEvent('esx_handcuffs:OutVehicle')
AddEventHandler('esx_handcuffs:OutVehicle', function(t)
  local ped = GetPlayerPed(t)
  ClearPedTasksImmediately(ped)
  plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
  local xnew = plyPos.x+2
  local ynew = plyPos.y+2

  SetEntityCoords(GetPlayerPed(-1), xnew, ynew, plyPos.z)
end)

-- ??
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not changed then
            ped = PlayerPedId()
            local IsCuffed = IsPedCuffed(ped)
            if IsCuffed and not IsEntityPlayingAnim(PlayerPedId(), dict, anim, 3) then
                Citizen.Wait(0)
                TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)
            end
        else
            changed = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        ped = PlayerPedId()
        if cuffed then
        end
    end
end)
