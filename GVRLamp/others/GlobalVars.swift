//
//  GlobalVars.swift
//  GyverLamp
//
//  Created by Максим Казачков on 09.01.2022.
//  Copyright © 2022 Maksim Kazachkov. All rights reserved.
//

import Foundation
import UIKit

enum ModeOfSearch{
    case firstStartSearch //поиск при первом запуске
    case searchInRouterMode // поиск при подключении лампы к роутеру
    case searchInSpotMode // поиск при работе лампы в режиме точки доступа
}

enum selectorFlag {
    case effects
    case days
    case dawn
}

enum LangApp {
    case ru
    case en
    case ua
}

// команды, которые можно передать на лампу
enum CommandsToLamp: String {
    case power_on = "P_ON" // включить
    case power_off = "P_OFF" // выключить
    case eff = "EFF" // номер эффекта
    case get = "GET-" // запрос состояния
    case txt = "TXT-" // отправка бегущей стрjки
    case deb = "DEB"
    case bri = "BRI" // установка яркости
    case spd = "SPD" // установка скорости
    case sca = "SCA" // установка масштаба
    case gbr = "GBR" //
    case list = "LIST" // запрос списка эффектов
    case timer = "TMR_SET" // установка таймера
    case timer_get = "TMR_GET" // запрос состояния таймера
    case alarm_on
    case alarm_off
    case alarm = "ALM_SET" // установка будильника
    case button_on = "BTN ON" // включение кнопки на лампе
    case button_off = "BTN OFF" // отключение кнопки на лампе
    case dawn = "DAWN" // рассвет
    case fav_get = "FAV_GET" // набор эффектов для автопереключения запросить
    case fav_set = "FAV_SET" // набор эффектов для автопереключения установить
    case rnd = "RND_" //
    case blank = ""
    case lang = "LANG"
}

let redColor = UIColor(red: 220.0 / 255.0, green: 78.0 / 255.0, blue: 65.0 / 255.0, alpha: 1)
let blackColor = UIColor(red: 32.0 / 255.0, green: 34.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
let violetColor = UIColor(red: 115.0 / 255.0, green: 112.0 / 255.0, blue: 249.0 / 255.0, alpha: 1)
