# Приложение GVR Lamp
<img src="https://github.com/Kazachmak/GVRLamp/blob/master/icon.png" align="center" height="40" width="40">

<img src="https://github.com/Kazachmak/GVRLamp/blob/master/demo1.gif" width="250"/>  <img src="https://github.com/Kazachmak/GVRLamp/blob/master/demo2.gif" width="250"/>  <img src="https://github.com/Kazachmak/GVRLamp/blob/master/demo3.gif" width="250"/>

Приложение под iOS для управления лампой Гайвера.
Предназначено для использования с прошивками GUNNER47 v1.4 - 1.5, прошивкой "XX в 1" и FieryLedLamp.

Функции:
1. Автоматический поиск и добавление ламп в локальной сети.
2. Хранение списка ламп.
3. Загрузка списка эффектов из лампы.
4. Установка таймера выключения.
5. Установка будильников.
6. Автопереключение выбранных эффектов.
7. Отправка текущего времени в лампу.
8. Выключение кнопки на лампе.

## История версий

### 1.1
1. Реализовано управление несколькими выбранными лампами одновременно (сделайте свайп влево для добавления лампы с группу управляемых).
2. Добавлена отправка текста бегущей строки.
3. Диапазоны скорости и масштаба считываются из лампы для каждого эффекта.
4. Доработан интерфейс будильника.
5. Время на лампе синхронизируется постоянно с приложением.
6. Исправлены известные баги.

### 1.2
1. Добавлена мультиязычность. Доступные языки интерфейса: Русский, Украинский, Английский
2. Добавлена возможность выбирать любимые эффекты и переключаться только между ними
3. Ускорена синхронизация в режиме работы ламп в группе
4. Улучшен интерфейс, включая более простое переключение между эффектами
5. Улучшено быстродействие
6. Исправлена работа будильника и другие известные баги.
7. Частота опроса лампы увеличена до 1 Гц.

### 1.3
1. Доработан и улучшен интерфейс, включая быстрый автоматический поиск подключенных ламп.
2. Добавлена возможность переключать режим работы лампы (с роутером/без роутера) и подключать лампу к роутеру прямо из приложения.
3. Интегрирован веб-интерфейс и возможность легко обновлять прошивку лампы через загрузку файлов прошивки по WiFi
4. Добавлена мультиязычность для названий эффектов лампы.
5. Исправлены мелкие баги.

### 1.41
1. Улучшена локализация. Смена языка интерфейса приложения меняет и язык названий эффектов соответсвенно, которые загружаются с лампы.
2. Исправлены мелкие баги
Для разработчиков:
Изменён механизм локализации. Теперь можно менять язык web-интерфейса в лампе, если прошивка поддерживает обработку команды LANGxx, где хх может принимать значения en,ru,ua.

### 1.42
1. Улучшена совместимость с прошивкой FieryLedLamp.
2. Исправлены мелкие баги

## Автор

Максим Казачков, kazachmak@gmail.com

## Лицензия

MIT license
