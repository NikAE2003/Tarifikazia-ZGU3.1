﻿#Область ПрограммныйИнтерфейс
// Сведения о внешней обработке
// 
// Возвращаемое значение:
//   См. ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке
//
Функция СведенияОВнешнейОбработке() Экспорт
	 
	ВерсияБСП = СтандартныеПодсистемыСервер.ВерсияБиблиотеки();
	ПараметрыРегистрации = ДополнительныеОтчетыИОбработки.СведенияОВнешнейОбработке(ВерсияБСП);
	ПараметрыРегистрации.Информация = НСтр("ru = 'Тарификация'");
	ПараметрыРегистрации.Вид = ДополнительныеОтчетыИОбработкиКлиентСервер.ВидОбработкиДополнительныйОтчет();
	ПараметрыРегистрации.Версия = "1.0";
	ПараметрыРегистрации.ОпределитьНастройкиФормы = Истина;
	ПараметрыРегистрации.БезопасныйРежим = Ложь;
	
	Команда = ПараметрыРегистрации.Команды.Добавить();
	Команда.Представление = НСтр("ru = 'Тарификация'");
	Команда.Идентификатор = "Тарификация";
	Команда.Использование = ДополнительныеОтчетыИОбработкиКлиентСервер.ТипКомандыОткрытиеФормы();
	Команда.ПоказыватьОповещение = Ложь;
	
	Возврат ПараметрыРегистрации;
	 
КонецФункции
#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	НастройкиОтчета = КомпоновщикНастроек.ПолучитьНастройки();
	
	ПараметрыОтчета = Новый Структура;
	ПараметрыОтчета.Вставить("Период");
	ПараметрыОтчета.Вставить("ВыводитьСовмещения");
	ПараметрыОтчета.Вставить("ВыводитьНадбавкуЗаСовмещениеВСтрокеСовмещения");
	ЗаполнитьПараметрыОтчета(ПараметрыОтчета);
	
	Если НЕ ПараметрыОтчета.ВыводитьСовмещения Тогда
		ПараметрыОтчета.ВыводитьНадбавкуЗаСовмещениеВСтрокеСовмещения = Ложь;
	КонецЕсли;
	
	КадровыеДанные = КадровыеДанные(ДанныеРасшифровки, НастройкиОтчета, ПараметрыОтчета);
	
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	ЗарплатаКадры.СоздатьВТПоТаблицеЗначений(МенеджерВременныхТаблиц, КадровыеДанные, "ВТКадровыеДанные");
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Данные.Сотрудник КАК Сотрудник,
		|	Данные.Период КАК Период
		|ПОМЕСТИТЬ ВТСотрудникиПериоды
		|ИЗ
		|	ВТКадровыеДанные КАК Данные
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Данные.ФизическоеЛицо КАК ФизическоеЛицо,
		|	Данные.Период КАК Период
		|ПОМЕСТИТЬ ВТФизическиеЛицаПериоды
		|ИЗ
		|	ВТКадровыеДанные КАК Данные";
	Запрос.Выполнить();
	
	СоздатьВТДанныеНачислений(МенеджерВременныхТаблиц);
	
	БазовыеВидыРасчетаНачислений = БазовыеВидыРасчетаНачислений(МенеджерВременныхТаблиц);
	Показатели = ЗначенияПоказателей(МенеджерВременныхТаблиц);
	Начисления = ДанныеНачислений(МенеджерВременныхТаблиц, ПараметрыОтчета);
	
	ДанныеОтчета = ТаблицаДанныхОтчета(БазовыеВидыРасчетаНачислений, ПараметрыОтчета, КадровыеДанные, Начисления, Показатели);
	
	МакетКомпоновки = ЗарплатаКадрыОтчеты.МакетКомпоновкиДанных(СхемаКомпоновкиДанных, НастройкиОтчета, ДанныеРасшифровки);
	
	МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	ЗарплатаКадры.СоздатьВТПоТаблицеЗначений(МенеджерВременныхТаблиц, КадровыеДанные, "ВТКадровыеДанные");
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, Новый Структура("Данные", ДанныеОтчета), ДанныеРасшифровки, Истина, Ложь, МенеджерВременныхТаблиц);
		
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область отладка
Процедура ВывестиВТВТабличныйДокумент(МенеджерВременныхТаблиц, ИмяВТ, ДокументРезультат)

	ВывестиТаблицуЗначенийВТабличныйДокумент(ТаблицаЗначенийИзВТ(МенеджерВременныхТаблиц, ИмяВТ), ДокументРезультат);

КонецПроцедуры

Процедура ВывестиТаблицуЗначенийВТабличныйДокумент(Таблица, ДокументРезультат)

	ПострПечать = Новый ПостроительОтчета;
    ПострПечать.ИсточникДанных = Новый ОписаниеИсточникаДанных(Таблица);
    ПострПечать.Выполнить();
    Для каждого Колонка Из ПострПечать.ВыбранныеПоля Цикл
        Колонка.Представление = Таблица.Колонки[Колонка.Имя].Заголовок;
    КонецЦикла; 
    ПострПечать.Вывести(ДокументРезультат);

КонецПроцедуры

Функция ТаблицаЗначенийИзВТ(МенеджерВременныхТаблиц, ИмяВТ, Колонки = Неопределено)

	Запрос = Новый Запрос(СтрШаблон("ВЫБРАТЬ ВТ.* ИЗ %1 КАК ВТ", ИмяВТ));
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	
	Если ЗначениеЗаполнено(Колонки) Тогда
	
		мКолонки = СтрРазделить(Колонки, ", ", Ложь);
		
		Для сч = 0 По мКолонки.ВГраница() Цикл
			мКолонки[сч] = "ВТ." + мКолонки[сч];		
		КонецЦикла;
		
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "ВТ.*", СтрСоединить(мКолонки, ", "));
	
	КонецЕсли;
	
	Возврат Запрос.Выполнить().Выгрузить();

КонецФункции // ()
#КонецОбласти

#Область ПолучениеДанных

Функция КадровыеДанные(ДанныеРасшифровки, НастройкиОтчета, ПараметрыОтчета)

	СхемаКД = ПолучитьМакет("СКД_КадровыеДанные");
	ПередПолучениемКадровыхДанных(СхемаКД, ПараметрыОтчета);
	
	КомпоновщикНастроекКадровыДанные = Новый КомпоновщикНастроекКомпоновкиДанных;
	КомпоновщикНастроекКадровыДанные.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(СхемаКД));
	
	НастройкиОтчетаКадровыДанные = КомпоновщикНастроекКадровыДанные.ПолучитьНастройки();
	
	НастройкиОтчетаКадровыДанные.Структура.Очистить();
	
	Группировка = НастройкиОтчетаКадровыДанные.Структура.Добавить(Тип("ГруппировкаКомпоновкиДанных"));
	Группировка.ПоляГруппировки.Элементы.Очистить();
	Группировка.Выбор.Элементы.Очистить();
	Группировка.Выбор.Элементы.Добавить(Тип("АвтоВыбранноеПолеКомпоновкиДанных"));
	
	ПоляНабораДанных = СхемаКД.НаборыДанных.Найти("КадровыеДанные").Поля;
	Для каждого Поле Из ПоляНабораДанных Цикл
		ОтчетыСервер.ДобавитьВыбранноеПоле(НастройкиОтчетаКадровыДанные, Поле.ПутьКДанным);
	КонецЦикла;
	
	Для каждого Параметр Из ПараметрыОтчета Цикл
		ПараметрКомпоновкиДанных = Новый ПараметрКомпоновкиДанных(Параметр.Ключ);
		Если НастройкиОтчетаКадровыДанные.ПараметрыДанных.ДоступныеПараметры.НайтиПараметр(ПараметрКомпоновкиДанных) <> Неопределено Тогда
			НастройкиОтчетаКадровыДанные.ПараметрыДанных.УстановитьЗначениеПараметра(ПараметрКомпоновкиДанных, Параметр.Значение);	
		КонецЕсли;
	КонецЦикла;
	
	Отбор = НастройкиОтчета.Отбор.Элементы;
	Для каждого ЭлементОтбора Из Отбор Цикл
		Если ТипЗнч(ЭлементОтбора) = Тип("ЭлементОтбораКомпоновкиДанных") И ЭлементОтбора.Использование Тогда
			ЗарплатаКадрыОтчеты.ДобавитьЭлементОтбора(
				НастройкиОтчетаКадровыДанные.Отбор, 
				Строка(ЭлементОтбора.ЛевоеЗначение), 
				ЭлементОтбора.ВидСравнения,
				ЭлементОтбора.ПравоеЗначение
			);
		КонецЕсли;
	КонецЦикла;
	
	МакетКомпоновки = ЗарплатаКадрыОтчеты.МакетКомпоновкиДанныхДляКоллекцииЗначений(СхемаКД, НастройкиОтчетаКадровыДанные, ДанныеРасшифровки);
	
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;	
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки, , ДанныеРасшифровки);
		
	ДанныеОтчета = Новый ТаблицаЗначений;
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ПроцессорВывода.УстановитьОбъект(ДанныеОтчета);
	ПроцессорВывода.Вывести(ПроцессорКомпоновки);
	
	Возврат ДанныеОтчета;
	
КонецФункции

Процедура СоздатьВТДанныеНачислений(МенеджерВременныхТаблиц)
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПлановыеНачисленияИнтервальный.Сотрудник КАК Сотрудник,
	|	ПлановыеНачисленияИнтервальный.Начисление КАК Начисление,
	|	ПлановыеНачисленияИнтервальный.Начисление.ОчередностьРасчета КАК ОчередностьРасчета,
	|	ПлановыеНачисленияИнтервальный.Начисление.ФормулаРасчетаДляВыполнения КАК ФормулаРасчетаДляВыполнения,
	|	ВЫБОР
	|		КОГДА ПлановыеНачисленияИнтервальный.ДокументОснование = НЕОПРЕДЕЛЕНО
	|			ТОГДА ЗНАЧЕНИЕ(Документ.Совмещение.ПустаяСсылка)
	|		ИНАЧЕ ПлановыеНачисленияИнтервальный.ДокументОснование
	|	КОНЕЦ КАК ДокументОснование,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(ПлановыйФОТ.ВкладВФОТ, 0) = 0
	|			ТОГДА ПлановыеНачисленияИнтервальный.Размер
	|		ИНАЧЕ ПлановыйФОТ.ВкладВФОТ
	|	КОНЕЦ КАК Размер,
	|	ПлановыеНачисленияИнтервальный.ДействуетДо КАК ДействуетДо
	|ПОМЕСТИТЬ ВТДанныеНачислений
	|ИЗ
	|	ВТСотрудникиПериоды КАК ВТСотрудникиПериоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ПлановыеНачисленияИнтервальный КАК ПлановыеНачисленияИнтервальный
	|		ПО ВТСотрудникиПериоды.Сотрудник = ПлановыеНачисленияИнтервальный.Сотрудник
	|			И (КОНЕЦПЕРИОДА(ВТСотрудникиПериоды.Период, ДЕНЬ) МЕЖДУ ПлановыеНачисленияИнтервальный.ДатаНачала И ПлановыеНачисленияИнтервальный.ДатаОкончания)
	|			И (ПлановыеНачисленияИнтервальный.Используется)
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПлановыйФОТ КАК ПлановыйФОТ
	|		ПО ВТСотрудникиПериоды.Сотрудник = ПлановыйФОТ.Сотрудник
	|			И (ПлановыеНачисленияИнтервальный.Начисление = ПлановыйФОТ.Начисление)
	|			И (ПлановыеНачисленияИнтервальный.ДокументОснование = ПлановыйФОТ.ДокументОснование)
	|			И (КОНЕЦПЕРИОДА(ВТСотрудникиПериоды.Период, ДЕНЬ) МЕЖДУ ПлановыйФОТ.Период И ПлановыйФОТ.ДатаОкончания)";
	Запрос.Выполнить();

КонецПроцедуры

Функция БазовыеВидыРасчетаНачислений(МенеджерВременныхТаблиц)
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТДанныеНачислений.Начисление КАК Начисление
	|ПОМЕСТИТЬ ВТВсеНачисления
	|ИЗ
	|	ВТДанныеНачислений КАК ВТДанныеНачислений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТВсеНачисления.Начисление КАК Начисление,
	|	НачисленияБазовыеВидыРасчета.ВидРасчета КАК БазовыйВидРасчета
	|ИЗ
	|	ВТВсеНачисления КАК ВТВсеНачисления
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПланВидовРасчета.Начисления.БазовыеВидыРасчета КАК НачисленияБазовыеВидыРасчета
	|		ПО (ВТВсеНачисления.Начисление = НачисленияБазовыеВидыРасчета.Ссылка
	|				И ВТВсеНачисления.Начисление <> НачисленияБазовыеВидыРасчета.ВидРасчета)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТВсеНачисления КАК ОтборБазовыхВидовРасчета
	|		ПО (НачисленияБазовыеВидыРасчета.ВидРасчета = ОтборБазовыхВидовРасчета.Начисление)";
	Выборка = Запрос.Выполнить().Выбрать();
	
	БазовыеВидыРасчетаНачислений = Новый Соответствие;
	Пока Выборка.Следующий() Цикл
		мБазовыеВидыРасчета = БазовыеВидыРасчетаНачислений.Получить(Выборка.Начисление);
		Если мБазовыеВидыРасчета = Неопределено Тогда
			мБазовыеВидыРасчета = Новый Соответствие;
			БазовыеВидыРасчетаНачислений.Вставить(Выборка.Начисление, мБазовыеВидыРасчета);
		КонецЕсли;	
		
		мБазовыеВидыРасчета.Вставить(Выборка.БазовыйВидРасчета, Истина);
	КонецЦикла;
	
	Возврат БазовыеВидыРасчетаНачислений;

КонецФункции

Функция ЗначенияПоказателей(МенеджерВременныхТаблиц)
	
	ОписательВТ = КадровыйУчетРасширенный.ОписательВременнойТаблицыОтборовДляВТСтажиФизическихЛиц("ВТФизическиеЛицаПериоды");
	КадровыйУчетРасширенный.СоздатьВТСтажиФизическихЛиц(МенеджерВременныхТаблиц, Истина, ОписательВТ);
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = МенеджерВременныхТаблиц;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВТСотрудникиПериоды.Сотрудник КАК Сотрудник,
	|	ВТСотрудникиПериоды.Период КАК Период,
	|	ВТДанныеНачислений.Начисление КАК Начисление,
	|	ВТДанныеНачислений.ДокументОснование КАК ДокументОснование,
	|	НачисленияПоказатели.Показатель КАК Показатель,
	|	НачисленияПоказатели.Показатель.Идентификатор КАК Идентификатор,
	|	НачисленияПоказатели.Показатель.ВидСтажа КАК ВидСтажа,
	|	НачисленияПоказатели.Показатель.ТипПоказателя = ЗНАЧЕНИЕ(Перечисление.ТипыПоказателейРасчетаЗарплаты.ЧисловойЗависящийОтСтажа) КАК ЭтоСтажевыйПоказатель,
	|	НачисленияПоказатели.Показатель.ИмяПредопределенныхДанных = ""СевернаяНадбавка"" КАК ЭтоСевернаяНадбавка,
	|	НачисленияПоказатели.ОсновнойПоказатель КАК ОсновнойПоказатель
	|ПОМЕСТИТЬ ВТПоказателиСотрудников
	|ИЗ
	|	ВТСотрудникиПериоды КАК ВТСотрудникиПериоды
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТДанныеНачислений КАК ВТДанныеНачислений
	|		ПО ВТСотрудникиПериоды.Сотрудник = ВТДанныеНачислений.Сотрудник
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПланВидовРасчета.Начисления.Показатели КАК НачисленияПоказатели
	|		ПО (ВТДанныеНачислений.Начисление = НачисленияПоказатели.Ссылка)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВТПоказателиСотрудников.Показатель КАК Показатель
	|ПОМЕСТИТЬ ВТСтажевыеПоказатели
	|ИЗ
	|	ВТПоказателиСотрудников КАК ВТПоказателиСотрудников
	|ГДЕ
	|	ВТПоказателиСотрудников.ЭтоСтажевыйПоказатель = ИСТИНА
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТСтажевыеПоказатели.Показатель КАК Показатель,
	|	ЕСТЬNULL(ПоказателиРасчетаЗарплатыШкалаОценкиСтажа1.ВерхняяГраницаИнтервалаСтажа, 0) КАК НижняяГраница,
	|	ВЫБОР
	|		КОГДА ПоказателиРасчетаЗарплатыШкалаОценкиСтажа.ВерхняяГраницаИнтервалаСтажа = 0
	|			ТОГДА 999
	|		ИНАЧЕ ПоказателиРасчетаЗарплатыШкалаОценкиСтажа.ВерхняяГраницаИнтервалаСтажа - 1
	|	КОНЕЦ КАК ВерхняяГраница,
	|	ПоказателиРасчетаЗарплатыШкалаОценкиСтажа.ЗначениеПоказателя КАК Значение
	|ПОМЕСТИТЬ ВТИнтервалыСтажа
	|ИЗ
	|	ВТСтажевыеПоказатели КАК ВТСтажевыеПоказатели
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПоказателиРасчетаЗарплаты.ШкалаОценкиСтажа КАК ПоказателиРасчетаЗарплатыШкалаОценкиСтажа
	|		ПО ВТСтажевыеПоказатели.Показатель = ПоказателиРасчетаЗарплатыШкалаОценкиСтажа.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПоказателиРасчетаЗарплаты.ШкалаОценкиСтажа КАК ПоказателиРасчетаЗарплатыШкалаОценкиСтажа1
	|		ПО ВТСтажевыеПоказатели.Показатель = ПоказателиРасчетаЗарплатыШкалаОценкиСтажа1.Ссылка
	|			И (ПоказателиРасчетаЗарплатыШкалаОценкиСтажа.НомерСтроки = ПоказателиРасчетаЗарплатыШкалаОценкиСтажа1.НомерСтроки + 1)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТПоказателиСотрудников.Сотрудник КАК Сотрудник,
	|	ВТПоказателиСотрудников.Начисление КАК Начисление,
	|	ВТПоказателиСотрудников.ДокументОснование КАК ДокументОснование,
	|	ВТПоказателиСотрудников.Показатель КАК Показатель,
	|	ВТПоказателиСотрудников.Идентификатор КАК Идентификатор,
	|	ВТПоказателиСотрудников.ОсновнойПоказатель КАК ОсновнойПоказатель,
	|	ЗначенияПоказателей.Значение КАК Значение,
	|	ЗНАЧЕНИЕ(Справочник.ВидыСтажа.ПустаяСсылка) КАК ВидСтажа,
	|	0 КАК РазмерМесяцев,
	|	0 КАК РазмерДней,
	|	0 КАК Прерван,
	|	0 КАК ВсегоМесяцев,
	|	0 КАК Лет,
	|	0 КАК Месяцев,
	|	0 КАК Дней
	|ИЗ
	|	ВТПоказателиСотрудников КАК ВТПоказателиСотрудников
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияПериодическихПоказателейРасчетаЗарплатыСотрудниковИнтервальный КАК ЗначенияПоказателей
	|		ПО ВТПоказателиСотрудников.Сотрудник = ЗначенияПоказателей.Сотрудник
	|			И ВТПоказателиСотрудников.Показатель = ЗначенияПоказателей.Показатель
	|			И (ВТПоказателиСотрудников.ДокументОснование = ВЫБОР
	|				КОГДА ЗначенияПоказателей.ДокументОснование = НЕОПРЕДЕЛЕНО
	|					ТОГДА ЗНАЧЕНИЕ(Документ.Совмещение.ПустаяСсылка)
	|				ИНАЧЕ ЗначенияПоказателей.ДокументОснование
	|			КОНЕЦ)
	|			И (КОНЕЦПЕРИОДА(ВТПоказателиСотрудников.Период, ДЕНЬ) МЕЖДУ ЗначенияПоказателей.ДатаНачала И ЗначенияПоказателей.ДатаОкончания)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТПоказателиСотрудников.Сотрудник,
	|	ВТПоказателиСотрудников.Начисление,
	|	ВТПоказателиСотрудников.ДокументОснование,
	|	ВТПоказателиСотрудников.Показатель,
	|	ВТПоказателиСотрудников.Идентификатор,
	|	ВТПоказателиСотрудников.ОсновнойПоказатель,
	|	ВТИнтервалыСтажа.Значение,
	|	ВТСтажиФизическихЛиц.ВидСтажа,
	|	ВТСтажиФизическихЛиц.РазмерМесяцев,
	|	ВТСтажиФизическихЛиц.РазмерДней,
	|	ВТСтажиФизическихЛиц.Прерван,
	|	ВТСтажиФизическихЛиц.ВсегоМесяцев,
	|	ВТСтажиФизическихЛиц.Лет,
	|	ВТСтажиФизическихЛиц.Месяцев,
	|	ВТСтажиФизическихЛиц.Дней
	|ИЗ
	|	ВТПоказателиСотрудников КАК ВТПоказателиСотрудников
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТИнтервалыСтажа КАК ВТИнтервалыСтажа
	|		ПО ВТПоказателиСотрудников.Показатель = ВТИнтервалыСтажа.Показатель
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТСтажиФизическихЛиц КАК ВТСтажиФизическихЛиц
	|		ПО (ВЫРАЗИТЬ(ВТПоказателиСотрудников.Сотрудник КАК Справочник.Сотрудники).ФизическоеЛицо = ВТСтажиФизическихЛиц.ФизическоеЛицо)
	|			И ВТПоказателиСотрудников.Показатель.ВидСтажа = ВТСтажиФизическихЛиц.ВидСтажа
	|			И ВТПоказателиСотрудников.Период = ВТСтажиФизическихЛиц.Период
	|			И (ВТСтажиФизическихЛиц.ВсегоМесяцев МЕЖДУ ВТИнтервалыСтажа.НижняяГраница И ВТИнтервалыСтажа.ВерхняяГраница)
	|ГДЕ
	|	ВТПоказателиСотрудников.ЭтоСтажевыйПоказатель
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВТПоказателиСотрудников.Сотрудник,
	|	ВТПоказателиСотрудников.Начисление,
	|	ВТПоказателиСотрудников.ДокументОснование,
	|	ВТПоказателиСотрудников.Показатель,
	|	ВТПоказателиСотрудников.Идентификатор,
	|	ВЫРАЗИТЬ(ВТПоказателиСотрудников.Начисление КАК ПланВидовРасчета.Начисления).КатегорияНачисленияИлиНеоплаченногоВремени = ЗНАЧЕНИЕ(Перечисление.КатегорииНачисленийИНеоплаченногоВремени.СевернаяНадбавка),
	|	ПроцентыСевернойНадбавкиФизическихЛиц.ПроцентСевернойНадбавки,
	|	ЗНАЧЕНИЕ(Справочник.ВидыСтажа.ПустаяСсылка),
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0,
	|	0
	|ИЗ
	|	ВТПоказателиСотрудников КАК ВТПоказателиСотрудников
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ПроцентыСевернойНадбавкиФизическихЛиц КАК ПроцентыСевернойНадбавкиФизическихЛиц
	|		ПО (ВЫРАЗИТЬ(ВТПоказателиСотрудников.Сотрудник КАК Справочник.Сотрудники).ФизическоеЛицо = ПроцентыСевернойНадбавкиФизическихЛиц.ФизическоеЛицо)
	|			И (ВТПоказателиСотрудников.Период МЕЖДУ ПроцентыСевернойНадбавкиФизическихЛиц.Период И КОНЕЦПЕРИОДА(ПроцентыСевернойНадбавкиФизическихЛиц.ДействуетДо, ДЕНЬ))
	|ГДЕ
	|	ВТПоказателиСотрудников.ЭтоСевернаяНадбавка";
	
	ЗначенияПоказателей = Запрос.Выполнить().Выгрузить();
	ЗначенияПоказателей.Индексы.Добавить("Сотрудник, Начисление, ДокументОснование");
	
	Возврат ЗначенияПоказателей;

КонецФункции

Функция ДанныеНачислений(МенеджерВременныхТаблиц, ПараметрыОтчета)
	
	Начисления = ТаблицаЗначенийИзВТ(МенеджерВременныхТаблиц, "ВТДанныеНачислений");
	Если ПараметрыОтчета.ВыводитьНадбавкуЗаСовмещениеВСтрокеСовмещения Тогда // #std452
		Начисления.Индексы.Добавить("Сотрудник, ДокументОснование");
	Иначе
		Начисления.Индексы.Добавить("Сотрудник");
	КонецЕсли;
	
	ОбъектСравнения = Новый СравнениеЗначений;
	Начисления.Сортировать("Сотрудник, ОчередностьРасчета", ОбъектСравнения);
	Возврат Начисления;

КонецФункции

Функция ТаблицаДанныхОтчета(БазовыеВидыРасчетаНачислений, ПараметрыОтчета, КадровыеДанные, Начисления, Показатели)
	
	ДанныеОтчета = Новый ТаблицаЗначений;
	ПоляНабораДанных = СхемаКомпоновкиДанных.НаборыДанных.Найти("Тарификация").Элементы.Найти("ДанныеСотрудников").Поля;
	Для каждого Поле Из ПоляНабораДанных Цикл
		ДанныеОтчета.Колонки.Добавить(Поле.Поле, Поле.ТипЗначения);
	КонецЦикла;
	
	Для каждого СтрокаКадровыхДанных Из КадровыеДанные Цикл
		
		ОтборНачислений = Новый Структура("Сотрудник", СтрокаКадровыхДанных.Сотрудник);
		Если ПараметрыОтчета.ВыводитьНадбавкуЗаСовмещениеВСтрокеСовмещения Тогда
			ОтборНачислений.Вставить("ДокументОснование", СтрокаКадровыхДанных.ДокументОснование);
		КонецЕсли;
		
		Если НЕ ПараметрыОтчета.ВыводитьНадбавкуЗаСовмещениеВСтрокеСовмещения
			И СтрокаКадровыхДанных.ЭтоСовмещение Тогда
			НачисленияСотрудника = Новый Массив;
		Иначе
			НачисленияСотрудника = Начисления.НайтиСтроки(ОтборНачислений);
		КонецЕсли;
		
		НачислениеВыведено = Ложь;
		Для каждого СтрокаНачисления Из НачисленияСотрудника Цикл
			
			НачислениеВыведено = Истина;
			
			ОтборПоказателей = Новый Структура;
			ОтборПоказателей.Вставить("Сотрудник", СтрокаНачисления.Сотрудник);
			ОтборПоказателей.Вставить("Начисление", СтрокаНачисления.Начисление);
			ОтборПоказателей.Вставить("ДокументОснование", СтрокаНачисления.ДокументОснование);
			
			мПоказателиНачисления = Показатели.НайтиСтроки(ОтборПоказателей);
			
			Если НЕ ЗначениеЗаполнено(СтрокаНачисления.Размер) Тогда
				
				РасчитатьНачисление(БазовыеВидыРасчетаНачислений, мПоказателиНачисления, НачисленияСотрудника, СтрокаНачисления);
				
			КонецЕсли;
			
			НовСтрока = ДанныеОтчета.Добавить();
			ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаНачисления);
			ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаКадровыхДанных);
			НовСтрока.ДокументОснование = СтрокаКадровыхДанных.ДокументОснование;
			
			Для каждого СтрокаПоказателя Из мПоказателиНачисления Цикл
				Если СтрокаПоказателя.ОсновнойПоказатель Тогда
					ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаПоказателя);
					НовСтрока.ДокументОснование = СтрокаКадровыхДанных.ДокументОснование;
				Иначе 
					НовСтрока = ДанныеОтчета.Добавить();
					ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаНачисления);
					ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаПоказателя);
					ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаКадровыхДанных);
					НовСтрока.ДокументОснование = СтрокаКадровыхДанных.ДокументОснование;
					НовСтрока.Размер = 0;
				КонецЕсли;
			КонецЦикла;
			
		КонецЦикла;
		
		Если Не НачислениеВыведено Тогда
			
			НовСтрока = ДанныеОтчета.Добавить();
			ЗаполнитьЗначенияСвойств(НовСтрока, СтрокаКадровыхДанных);
			
		КонецЕсли;
		
	КонецЦикла;
	Возврат ДанныеОтчета;

КонецФункции

Процедура РасчитатьНачисление(БазовыеВидыРасчетаНачислений, мПоказателиНачисления, НачисленияСотрудника, СтрокаНачисления)
	
	ЗначенияПоказателейНачисления = Новый Структура;
	Для каждого СтрокаПоказателя Из мПоказателиНачисления Цикл
		ЗначенияПоказателейНачисления.Вставить(СтрокаПоказателя.Идентификатор, СтрокаПоказателя.Значение);
	КонецЦикла;
	
	БазовыеВидыРасчета = БазовыеВидыРасчетаНачислений[СтрокаНачисления.Начисление];
	
	РасчетнаяБаза = 0;
	Если ЗначениеЗаполнено(БазовыеВидыРасчета) Тогда
		Для каждого СтрокаБазовогоВидаРасчета Из НачисленияСотрудника Цикл
			Если СтрокаБазовогоВидаРасчета.ОчередностьРасчета >= СтрокаНачисления.ОчередностьРасчета Тогда
				Прервать;						
			КонецЕсли;
			Если БазовыеВидыРасчета[СтрокаБазовогоВидаРасчета.Начисление] <> Неопределено Тогда
				РасчетнаяБаза = РасчетнаяБаза + СтрокаБазовогоВидаРасчета.Размер;				
			КонецЕсли;			
		КонецЦикла;
	КонецЕсли;
	
	ЗначенияПоказателейНачисления.Вставить("РасчетнаяБаза", РасчетнаяБаза);
	
	Формула = СтрокаНачисления.ФормулаРасчетаДляВыполнения;
	Формула = СтрЗаменить(Формула, "ИсходныеДанные", "Параметры");
	
	Попытка
		СтрокаНачисления.Размер = ОбщегоНазначения.ВычислитьВБезопасномРежиме(Формула, ЗначенияПоказателейНачисления);
	Исключение
	КонецПопытки;

КонецПроцедуры

#КонецОбласти

Процедура ПередПолучениемКадровыхДанных(СхемаКД, ПараметрыОтчета)

	НаборДанных = СхемаКД.НаборыДанных.Найти("КадровыеДанные");
	ТекстЗапроса = НаборДанных.Запрос;
	
	Если ПараметрыОтчета.ВыводитьСовмещения Тогда
		ТекстЗапроса = ТекстЗапроса + Символы.ПС + "Объединить все" + Символы.ПС + ТекстЗапросаКадровыеДанныеСовмещений();
		НаборДанных.Запрос = ТекстЗапроса;
	КонецЕсли;

КонецПроцедуры

Функция ТекстЗапросаКадровыеДанныеСовмещений()

	Возврат 
	"ВЫБРАТЬ
	|	&Период КАК Период,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.Сотрудник КАК Сотрудник,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ФизическоеЛицо КАК ФизическоеЛицо,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.Владелец КАК Организация,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.Подразделение КАК Подразделение,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.Должность КАК Должность,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания КАК ДолжностьПоШтатномуРасписанию,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.КоличествоСтавок КАК КоличествоСтавок,
	|	ЗНАЧЕНИЕ(Перечисление.ВидыЗанятости.ПустаяСсылка) КАК ВидЗанятости,
	|	ДАТАВРЕМЯ(1, 1, 1) КАК ДатаПриема,
	|	ДАТАВРЕМЯ(1, 1, 1) КАК ДатаУвольнения,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ДокументОснование КАК ДокументОснование,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ДействуетДо КАК СовмещениеДействуетДо,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ЗамещаемыйСотрудник КАК ЗамещаемыйСотрудник,
	|	ИСТИНА КАК ЭтоСовмещение
	|ИЗ
	|	РегистрСведений.ЗанятостьПозицийШтатногоРасписанияИнтервальный КАК ЗанятостьПозицийШтатногоРасписанияИнтервальный
	|ГДЕ
	|	КОНЕЦПЕРИОДА(&Период, ДЕНЬ) МЕЖДУ ЗанятостьПозицийШтатногоРасписанияИнтервальный.ДатаНачала И ЗанятостьПозицийШтатногоРасписанияИнтервальный.ДатаОкончания
	|	И ЗанятостьПозицийШтатногоРасписанияИнтервальный.ВидЗанятостиПозиции = ЗНАЧЕНИЕ(Перечисление.ВидыЗанятостиПозицийШтатногоРасписания.Совмещена)
	|{ГДЕ
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.Сотрудник.*,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ФизическоеЛицо.*,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.Владелец.* КАК Организация,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.Подразделение.* КАК Подразделение,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.Должность.* КАК Должность,
	|	ЗанятостьПозицийШтатногоРасписанияИнтервальный.ПозицияШтатногоРасписания.* КАК ДолжностьПоШтатномуРасписанию}";

КонецФункции // ()

#Область РаботаСПараметрами
// Заполняет ОписаниеПараметров значениями параметров данных компоновщика настроек
// Имеется возможность группировки параметров
//
// Параметры:
//  ОписаниеПараметров - Структура - Ключи структуры должны соответствовать именам параметров в СКД:
//  * <ИмяКлюча>       - Структура - Такое поле является группой параметров, имена его полей должны соответствовать именам параметров в СКД
//                     - Массив    - Значение параметра будет записано в массиве
//                     - Соответствие - должно иметь ключ формата Соответствие<ИмяГруппыПараметров>, при этом в ОписаниеПараметров должно иметься 
//                                      свойство <ИмяГруппыПараметров> типа Структура.
//                                      В такое свойство будет записан результат СоответствиеЗначенийПараметров(ОписаниеПараметров.<ИмяГруппыПараметров>)
//
Процедура ЗаполнитьПараметрыОтчета(ОписаниеПараметров)
	ПараметрыОтчета = КомпоновщикНастроек.ПолучитьНастройки().ПараметрыДанных;
	
	ЗаполняемыеСоответствия = Новый Массив;
	
	Для каждого Поле Из ОписаниеПараметров Цикл
		
		Если ТипЗнч(Поле.Значение) = Тип("Структура") Тогда
			ЗаполнитьПараметрыОтчета(Поле.Значение);	
			Продолжить;
		ИначеЕсли ТипЗнч(Поле.Значение) = Тип("Соответствие") Тогда 
			ЗаполняемыеСоответствия.Добавить(Поле.Ключ);
			Продолжить;
		КонецЕсли;
		
		НуженМассив = ТипЗнч(Поле.Значение) = Тип("Массив");
		
		Параметр = ПараметрыОтчета.НайтиЗначениеПараметра(Новый ПараметрКомпоновкиДанных(Поле.Ключ));
		Если Параметр <> Неопределено
			И Параметр.Использование или ТипЗнч(Параметр.Значение) = Тип("Булево") Тогда
			Если ТипЗнч(Параметр.Значение) = Тип("СписокЗначений") Тогда
				ОписаниеПараметров.Вставить(Поле.Ключ, Параметр.Значение.ВыгрузитьЗначения());
			ИначеЕсли ТипЗнч(Параметр.Значение) = Тип("СтандартнаяДатаНачала") Тогда
				ОписаниеПараметров.Вставить(Поле.Ключ, Параметр.Значение.Дата);
			ИначеЕсли ТипЗнч(Параметр.Значение) = Тип("СтандартныйПериод") Тогда
				ОписаниеПараметров.Вставить(Поле.Ключ, Параметр.Значение);
				ОписаниеПараметров.Вставить(Поле.Ключ + "ДатаНачала", Параметр.Значение.ДатаНачала);
				ОписаниеПараметров.Вставить(Поле.Ключ + "ДатаОкончания", Параметр.Значение.ДатаОкончания);
			Иначе
				ОписаниеПараметров.Вставить(Поле.Ключ, Параметр.Значение);
			КонецЕсли;
		КонецЕсли;
		
		Если НуженМассив Тогда
			ЗначениеПараметраВМассиве(ОписаниеПараметров, Поле.Ключ);
		КонецЕсли;
	КонецЦикла;
	
	Для каждого Соответствие Из ЗаполняемыеСоответствия Цикл
		Параметры = Неопределено;
		Если ОписаниеПараметров.Свойство(СтрЗаменить(Соответствие, "Соответствие", ""), Параметры) Тогда
			ОписаниеПараметров.Вставить(Соответствие, СоответствиеЗначенийПараметров(Параметры));
		Иначе 
			ВызватьИсключение "В параметрах отчета не обнаружено поле """ + СтрЗаменить(Соответствие, "Соответствие", "") + """";
		КонецЕсли;	
	КонецЦикла;

КонецПроцедуры

Процедура ЗначениеПараметраВМассиве(Параметры, Ключ)
	Если Параметры.Свойство(Ключ) Тогда
		Если ТипЗнч(Параметры[Ключ]) <> Тип("Массив") Тогда
			Параметры.Вставить(Ключ, ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Параметры[Ключ]));		
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

Процедура ЗначенияПараметровВМассиве(Параметры)
	Для каждого Параметр Из Параметры Цикл
		ЗначениеПараметраВМассиве(Параметры, Параметр.Ключ);
	КонецЦикла;
КонецПроцедуры	

// Возвращает соответствие, где Ключ - значение парамера, значение - имя параметра
//
// Параметры:
//  Параметры - Структура - значения свойств должны быть типа Массив
// 
// Возвращаемое значение:
//   Соответствие:
//   * Ключ - Произвольный -
//   * Значение - Строка - Имя параметра
Функция СоответствиеЗначенийПараметров(Параметры)
	
	ЗначенияПараметровВМассиве(Параметры);
	
	ЗначенияПараметров = Новый Соответствие;
	Для каждого Поле Из Параметры Цикл
				
		Для каждого Значение Из Поле.Значение Цикл
			Если Значение <> Неопределено Тогда
				ЗначенияПараметров.Вставить(Значение, Поле.Ключ);	
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат ЗначенияПараметров;
КонецФункции // СоответствиеЗначенийПараметров()
#КонецОбласти
#КонецОбласти


