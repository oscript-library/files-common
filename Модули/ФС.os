/////////////////////////////////////////////////////////////////////
//
// Модуль часто используемых функций работы с файлами
//
// (с) EvilBeaver, 2016
//
/////////////////////////////////////////////////////////////////////


// Проверяет существование файла или каталога
//
// Параметры:
//   Путь - Проверяемый путь
//
//  Возвращаемое значение:
//   Булево   - Истина, если файл/каталог существует
//
Функция Существует(Знач Путь) Экспорт

    Объект = Новый Файл(Путь);

    Возврат Объект.Существует();

КонецФункции // Существует()

// Проверяет существование файла
//
// Параметры:
//   Путь - Проверяемый путь
//
//  Возвращаемое значение:
//   Булево   - Истина, если файл существует
//
Функция ФайлСуществует(Знач Путь) Экспорт

    Объект = Новый Файл(Путь);

    Возврат Объект.Существует() и Объект.ЭтоФайл();

КонецФункции // ФайлСуществует()

// Проверяет существование каталога
//
// Параметры:
//   Путь - Проверяемый путь
//
//  Возвращаемое значение:
//   Булево   - Истина, если каталог существует
//
Функция КаталогСуществует(Знач Путь) Экспорт

    Объект = Новый Файл(Путь);

    Возврат Объект.Существует() и Объект.ЭтоКаталог();

КонецФункции // КаталогСуществует()

// Гарантирует наличие пустого каталога с указанным именем
//
// Параметры:
//   Путь - Строка - Путь к каталогу
//
Процедура ОбеспечитьПустойКаталог(Знач Путь) Экспорт

    ОбеспечитьКаталог(Путь);
    УдалитьФайлы(Путь, ПолучитьМаскуВсеФайлы());

КонецПроцедуры // ОбеспечитьПустойКаталог()

// Гарантирует наличие каталога с указанным именем
//
// Параметры:
//   Путь - Строка - Путь к каталогу
//
Процедура ОбеспечитьКаталог(Знач Путь) Экспорт

    Объект = Новый Файл(Путь);
    Если Не Объект.Существует() Тогда
        СоздатьКаталог(Путь);
    ИначеЕсли НЕ Объект.ЭтоКаталог() Тогда
        ВызватьИсключение "Не удается создать каталог " + Путь + ". По данному пути уже существует файл.";
    КонецЕсли;

КонецПроцедуры // ОбеспечитьКаталог()

// Копирует все файлы из одного каталога в другой
//
// Параметры:
//   Откуда - Строка - Путь к исходному каталогу
//   Куда - Строка - Путь к каталогу-назначению
//
Процедура КопироватьСодержимоеКаталога(Знач Откуда, Знач Куда) Экспорт

	ОбеспечитьКаталог(Куда);

	Файлы = НайтиФайлы(Откуда, ПолучитьМаскуВсеФайлы());
	Для Каждого Файл Из Файлы Цикл
		ПутьКопирования = ОбъединитьПути(Куда, Файл.Имя);
		Если Файл.ЭтоКаталог() Тогда
			КопироватьСодержимоеКаталога(Файл.ПолноеИмя, ПутьКопирования);
		Иначе
			КопироватьФайл(Файл.ПолноеИмя, ПутьКопирования);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

// Проверяет является ли каталог пустым.
// Генерирует исключение если каталог с указанным именем не существует.
//
// Параметры:
//   Путь - Строка - Путь к каталогу
//
// Возвращаемое значение:
//   Булево   - Истина, если каталог пуст
//
Функция КаталогПустой(Знач Путь) Экспорт

	Если НЕ КаталогСуществует(Путь) Тогда
		ВызватьИсключение "Каталог <" + Путь + "> не существует";
	КонецЕсли;

	МассивФайлов = НайтиФайлы(Путь, ПолучитьМаскуВсеФайлы(), Ложь);

	Возврат МассивФайлов.Количество() = 0;

КонецФункции // КаталогПустой(Знач Путь)

// Возвращает путь файла относительно корневого каталога
// регистро-независимая замена, что важно для Windows в некоторых сценариях
//
// Параметры:
//   ПутьКорневогоКаталога - <Строка> - путь корневого каталога
//   ПутьВнутреннегоФайла - <Строка> - путь файла
//   РазделительПути - Строка или Неопределено - все разделители в пути заменяются на указанный разделитель пути
//		если Неопределено, то разделители пути не заменяются
//
//  Возвращаемое значение:
//   <Строка> - относительный путь файла
//
Функция ОтносительныйПуть(Знач ПутьКорневогоКаталога, Знач ПутьВнутреннегоФайла, Знач РазделительПути = Неопределено) Экспорт

	Если ПустаяСтрока(ПутьКорневогоКаталога) Тогда
		ВызватьИсключение "Не указан корневой путь в методе ФС.ОтносительныйПуть";
	КонецЕсли;

	ФайлКорень = Новый Файл(ПутьКорневогоКаталога);
	ФайлВнутреннийКаталог = Новый Файл(ПутьВнутреннегоФайла);

	ИмяДляРегулярки = ПодготовитьШаблонКИспользованиюВРегулярке(ФайлКорень.ПолноеИмя);
	РегулярноеВыражение = Новый РегулярноеВыражение(СтрШаблон("(%1)(.*)", ИмяДляРегулярки));
	Рез = РегулярноеВыражение.Заменить(ФайлВнутреннийКаталог.ПолноеИмя, "$2");

	Если Найти("\/", Лев(Рез, 1)) > 0 Тогда
		Рез = Сред(Рез, 2);
	КонецЕсли;
	Если Найти("\/", Прав(Рез, 1)) > 0 Тогда
		Рез = Лев(Рез, СтрДлина(Рез)-1);
	КонецЕсли;
	Если РазделительПути <> Неопределено Тогда
		Рез = СтрЗаменить(Рез, "\", РазделительПути);
		Рез = СтрЗаменить(Рез, "/", РазделительПути);
	КонецЕсли;

	Если ПустаяСтрока(Рез) Тогда
		Рез = ".";
	КонецЕсли;

	Возврат Рез;
КонецФункции

// Возращает полный путь, приведенный по правилам ОС.
//
// Параметры:
//  ОтносительныйИлиПолныйПуть  - фрагмент или полный путь
//
// Возвращаемое значение:
//   Строка   - путь, оформленный по правилам ОС
//
Функция ПолныйПуть(Знач ОтносительныйИлиПолныйПуть) Экспорт
	Файл = Новый Файл(ОтносительныйИлиПолныйПуть);
	Возврат Файл.ПолноеИмя;
КонецФункции // ПолныйПуть(Знач ОтносительныйИлиПолныйПуть) Экспорт


// Подготовить шаблон к использованию в регулярке путем экранирования служебных символов
//
// Параметры:
//  Шаблон	 - Строка - строка регулярного выражения без экранирования
//
// Возвращаемое значение:
//   Строка - подготовленный шаблон регулярного выражения с добавлением экранирования и заменой *
//
Функция ПодготовитьШаблонКИспользованиюВРегулярке(Знач Шаблон)

	СпецСимволы = Новый Массив;
	СпецСимволы.Добавить("\");
	СпецСимволы.Добавить("^");
	СпецСимволы.Добавить("$");
	СпецСимволы.Добавить("(");
	СпецСимволы.Добавить(")");
	СпецСимволы.Добавить("<");
	СпецСимволы.Добавить("[");
	СпецСимволы.Добавить("]");
	СпецСимволы.Добавить("{");
	СпецСимволы.Добавить("}");
	СпецСимволы.Добавить("|");
	СпецСимволы.Добавить(">");
	СпецСимволы.Добавить(".");
	СпецСимволы.Добавить("+");
	СпецСимволы.Добавить("?");
	СпецСимволы.Добавить("*");

	Для Каждого СпецСимвол Из СпецСимволы Цикл
		Шаблон = СтрЗаменить(Шаблон, СпецСимвол, "\" + СпецСимвол);
	КонецЦикла;

	Возврат Шаблон;

КонецФункции
