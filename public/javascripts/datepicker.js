/*
 * Control.DatePicker
 * 
 * Transforms an ordinary input textbox into an interactive date picker.
 * When the textbox is clicked (or the down arrow is pressed), a calendar
 * appears that the user can browse through and select a date.
 *
 * Features:
 *  - Allows user to specify a date format
 *  - Easy to localize
 *  - Customizable by CSS
 *
 * Written and maintained by Jeremy Jongsma (jeremy@jongsma.org)
 */
if (window.Control == undefined) Control = {};

Control.DatePicker = Class.create();
Control.DatePicker.prototype = {
	initialize: function(element, options) {
		this.element = $(element);
		this.i18n = new Control.DatePicker.i18n(options && options.locale ? options.locale : 'en_US');
		options = this.i18n.inheritOptions(options);
		this.options = Object.extend({
				onClick: this.pickerClicked.bind(this),
				onHover: this.dateHover.bind(this),
				onSelect: this.datePicked.bind(this)
			}, options || {});
		this.options.currentFormat = this.options.timePicker ? this.options.dateTimeFormat : this.options.dateFormat;
		this.options.date = DateFormat.parseFormat(this.element.value, this.options.currentFormat);
		this.datepicker = new Control.DatePickerPanel(this.options);

		this.originalValue = null;
		this.hideTimeout = null;

		if (this.options.icon) {
			this.icon = document.createElement('img');
			this.icon.src = this.options.icon;
			this.icon.title = this.tr('Open calendar');
			this.icon.className = 'inputExtension';
			var topOffset = /MSIE/.test(navigator.userAgent) ? '1px' : '3px';
			Element.setStyle(this.icon, {'position': 'relative', 'left': '-18px', 'top': topOffset});
			Element.insertAfter(this.icon, this.element);
			Event.observe(this.icon, 'click', this.togglePicker.bindAsEventListener(this));
		} else {
			Event.observe(this.element, 'click', this.togglePicker.bindAsEventListener(this));
		}

		this.hidePickerListener = this.delayedHide.bindAsEventListener(this);
		Event.observe(this.element, 'keypress', this.keyHandler.bindAsEventListener(this));
		Event.observe(document, 'keypress', this.docKeyHandler.bindAsEventListener(this));

		this.pickerActive = false;
	},
	tr: function(str) {
		return this.i18n.tr(str);
	},
	delayedHide: function(e) {
		this.hideTimeout = setTimeout(this.hide.bind(this), 100);
	},
	pickerClicked: function() {
		if (this.hideTimeout) {
			clearTimeout(this.hideTimeout);
			this.hideTimeout = null;
		}
	},
	datePicked: function(date) {
		this.element.value = DateFormat.format(date, this.options.currentFormat);
		this.element.focus();
		this.hide();
	},
	dateHover: function(date) {
		if (this.hideTimeout) {
			clearTimeout(this.hideTimeout);
			this.hideTimeout = null;
		}
		if (this.pickerActive)
			this.element.value = DateFormat.format(date, this.options.currentFormat);
	},
	togglePicker: function(e) {
		if (this.pickerActive) {
			this.element.value = this.originalValue;
			this.hide();
		} else {
			this.show();
		}
		Event.stop(e);
		return false;
	},
	docKeyHandler: function(e) {
		if (e.keyCode == Event.KEY_ESC)
			if (this.pickerActive) {
				this.element.value = this.originalValue;
				this.hide();
			}

	},
	keyHandler: function(e) {
		switch (e.keyCode) {
			case Event.KEY_ESC:
				if (this.pickerActive)
					this.element.value = this.originalValue;
			case Event.KEY_TAB:
				this.hide();
				return;
			case Event.KEY_DOWN:	
				if (!this.pickerActive)
					this.show();
		}
		if (this.pickerActive)
			return false;
	},
	hide: function() {
		if(this.pickerActive) {
			this.datepicker.releaseKeys();
			Element.remove(this.datepicker.element);
			Event.stopObserving(document, 'click', this.hidePickerListener, true);
			this.pickerActive = false;
		}
	},
	show: function () {
		if (!this.pickerActive) {
			this.originalValue = this.element.value;
			var pos = Position.cumulativeOffset(this.element);
			var dim = Element.getDimensions(this.element);
			var pickerTop = /MSIE/.test(navigator.userAgent) ? (pos[1] + dim.height) + 'px' : (pos[1] + dim.height - 1) + 'px';
			this.datepicker.element.style.top = pickerTop;
			this.datepicker.element.style.left = pos[0] + 'px';
			this.datepicker.selectDate(DateFormat.parseFormat(this.element.value, this.options.currentFormat));
			this.datepicker.captureKeys();
			document.body.appendChild(this.datepicker.element);
			Event.observe(document, 'click', this.hidePickerListener, true);
			this.pickerActive = true;
			this.pickerClicked();
		}
	}
};

Control.DatePicker.i18n = Class.create();
Object.extend(Control.DatePicker.i18n, {
	baseLocales: {
		'us': {
			dateTimeFormat: 'MM-dd-yyyy HH:mm',
			dateFormat: 'MM-dd-yyyy',
			firstWeekDay: 0,
			weekend: [0,6]
		},
		'eu': {
			dateTimeFormat: 'dd-MM-yyyy HH:mm',
			dateFormat: 'dd-MM-yyyy',
			firstWeekDay: 1,
			weekend: [0,6]
		},
		'iso8601': {
			dateTimeFormat: 'yyyy-MM-dd HH:mm',
			dateFormat: 'yyyy-MM-dd',
			firstWeekDay: 1,
			weekend: [0,6]
		}
	},
	
	createLocale: function(base, lang) {
		return Object.extend(Object.clone(Control.DatePicker.i18n.baseLocales[base]), {'language': lang});
	}
});
Control.DatePicker.i18n.prototype = {
	initialize: function(code) {
		var lang = code.charAt(2) == '_' ? code.substring(0,2) : code;
		var locale = (Control.DatePicker.Locale[code] || Control.DatePicker.Locale[lang]);
		this.opts = Object.clone(locale || {});
		var language = locale ? Control.DatePicker.Language[locale.language] : null;
		if (language) Object.extend(this.opts, language);
	},
	opts: null,
	inheritOptions: function(options) {
		if (!this.opts) this.setLocale('en_US');
		return Object.extend(this.opts, options || {});
	},
	tr: function(str) {
		return this.opts && this.opts.strings ? this.opts.strings[str] || str : str;
	}
};

Control.DatePicker.Locale = {};
with (Control.DatePicker) {
	// Full locale definitions not needed if countries use the language default format
	// Datepicker will fallback to the language default; i.e. 'es_AR' will use 'es'
	Locale['es'] = i18n.createLocale('eu', 'es');
	Locale['en'] = i18n.createLocale('us', 'en');
	Locale['en_GB'] = i18n.createLocale('eu', 'en');
	Locale['en_AU'] = Locale['en_GB'];
	Locale['de'] = i18n.createLocale('eu', 'de');
	Locale['fr'] = i18n.createLocale('eu', 'fr');
	Locale['es_iso8601'] = i18n.createLocale('iso8601', 'es');
	Locale['en_iso8601'] = i18n.createLocale('iso8601', 'en');
	Locale['de_iso8601'] = i18n.createLocale('iso8601', 'de');
}

Control.DatePicker.Language = {
	'es': {
		months: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Augosto', 'Septiembre', 'Octubre', 'Novimbre', 'Diciembre'],
		days: ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa'],
		strings: {
			'Now': 'Ahora',
			'Today': 'Hoy',
			'Time': 'Hora',
			'Exact minutes': 'Minuto exacto',
			'Select Date and Time': 'Selecciona Dia y Hora',
			'Open calendar': 'Abre calendario'
		}
	},
	'de': { 
		months: ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'], 
		days: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'], 
		strings: { 
			'Now': 'Jetzt', 
			'Today': 'Heute', 
			'Time': 'Zeit', 
			'Exact minutes': 'Exakte minuten', 
			'Select Date and Time': 'Zeit und Datum Auswählen',
			'Open calendar': 'Kalender öffnen'
		}
	},
	
	'fr': {
    months: ['Janvier', 'Fevrier', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Aout', 'Septembre', 
              'Octobre', 'Novembre', 'Devembre'],
    days: ['Di', 'Lu', 'Ma', 'Me', 'JE', 'Ve', 'Sa'], 
    strings: { 
      'Now': 'Maintenant', 
      'Today': 'today',
      'Time': 'time',
      'Exact minutes': 'Minute precise',
      'Select Date and Time': 'Selection date et heure',
      'Open calendar': 'Ouvrir calendrier'
    }
  }	
};


Control.DatePickerPanel = Class.create();
Object.extend(Control.DatePickerPanel.prototype, {
	initialize: function(options) {
		this.i18n = new Control.DatePicker.i18n(options && options.locale ? options.locale : 'en_US');
		options = this.i18n.inheritOptions(options);
		this.options = Object.extend({
						className: 'datepickerControl',
						closeOnToday: true,
						selectToday: true,
						showOnFocus: false,
						timePicker: false,
						firstWeekDay: 0,
						weekend: [0,6],
						months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
						days: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
					}, options || {});
		// Make sure first weekday is in the correct range
		with (this.options)
			if (isNaN(firstWeekDay*1)) firstWeekDay = 0;
			else firstWeekDay = firstWeekDay % 7;

		this.keysCaptured = false;
		this.calendarCont = null;
		this.currentDate = this.options.date ? this.options.date : new Date();
		this.dayOfWeek = 0;
		this.minInterval = 5;

		this.selectedDay = null;
		this.selectedHour = null;
		this.selectedMinute = null;
		this.selectedAmPm = null;

		this.currentDays = [];
		this.hourCells = [];
		this.minuteCells = [];
		this.otherMinutes = null;
		this.amCell = null;
		this.pmCell = null;

		this.element = this.createPicker();
		this.selectDate(this.currentDate);
	},
	createPicker: function() {
		var elt = document.createElement('div');
		elt.style.position = 'absolute';
		elt.className = this.options.className;
		this.calendarCont = this.drawCalendar(elt, this.currentDate);

		Event.observe(elt, 'click', this.clickHandler.bindAsEventListener(this));
		Event.observe(elt, 'dblclick', this.dblClickHandler.bindAsEventListener(this));
		this.documentKeyListener = this.keyHandler.bindAsEventListener(this);
		if (this.options.captureKeys)
			this.captureKeys();
		
		return elt;
	},
	tr: function(str) {
		return this.i18n.tr(str);
	},
	captureKeys: function() {
		Event.observe(document, 'keypress', this.documentKeyListener, true);
		this.keysCaptured = true;
	},
	releaseKeys: function() {
		Event.stopObserving(document, 'keypress', this.documentKeyListener, true);
		this.keysCaptured = false;
	},
	setDate: function(date) {
		if (date) {
			// Clear container
			while (this.calendarCont.firstChild)
				this.calendarCont.removeChild(this.calendarCont.firstChild);
			this.calendarCont.appendChild(this.createCalendar(date));
		}
	},
	drawCalendar: function(container, date) {
		var calCont = container;
		var calTable = this.createCalendar(date);

		if (this.options.timePicker) {
			var timeTable;
			if (this.options.timePickerAdjacent) {
				var rows = 0;

				var adjTable = document.createElement('table');
				adjTable.cellSpacing = 0;
				adjTable.cellPadding = 0;
				adjTable.border = 0;
				
				row = adjTable.insertRow(0);

				cell = row.insertCell(0);
				cell.vAlign = 'top';
				cell.appendChild(calTable);
				calCont = cell;

				cell = row.insertCell(1);
				cell.style.width = '5px';

				cell = row.insertCell(2);
				cell.vAlign = 'top';
				timeTable = document.createElement('table');
				timeTable.cellSpacing = 0;
				timeTable.cellPadding = 0;
				timeTable.border = 0;
				cell.appendChild(timeTable);

				container.appendChild(adjTable);

				row = timeTable.insertRow(rows++);
				row.className = 'monthLabel';
				cell = row.insertCell(0);
				cell.colSpan = 7;
				cell.innerHTML = this.tr('Time');

				row = timeTable.insertRow(rows++);
				cell = row.insertCell(0);
				cell.colSpan = 7;
				cell.style.height = '1px';

			} else {
				container.appendChild(calTable);
				timeTable = calTable;
				var rows = calTable.rows.length;

				row = timeTable.insertRow(rows++);
				cell = row.insertCell(0);
				cell.colSpan = 7;

				var hr = document.createElement('hr');
				Element.setStyle(hr, {'color': 'gray', 'backgroundColor': 'gray', 'height': '1px', 'border': '0', 'marginTop': '3px', 'marginBottom': '3px', 'padding': '0'});
				cell.appendChild(hr);
			}

			for (var j = 0; j < 2; ++j) {
				row = timeTable.insertRow(rows++);
				for (var i = 0; i < 6; ++i){
					cell = row.insertCell(i);
					cell.className = 'hour';
					cell.width = '14%';
					cell.innerHTML = (j*6)+i+1;
					cell.onclick = this.hourClickedListener((j*6)+i+1);
					this.hourCells[(j*6)+i] = cell;
				}
				cell = row.insertCell(i);
				cell.className = 'ampm';
				cell.width = '14%';
				if (j) {
					cell.innerHTML = this.tr('PM');
					cell.onclick = this.pmClickedListener();
					this.pmCell = cell;
				} else {
					cell.innerHTML = this.tr('AM');
					cell.onclick = this.amClickedListener();
					this.amCell = cell;
				}
			}

			row = timeTable.insertRow(rows++);
			cell = row.insertCell(0);
			cell.colSpan = 6;

			var hr = document.createElement('hr');
			Element.setStyle(hr, {'color': '#CCCCCC', 'backgroundColor': '#CCCCCC', 'height': '1px', 'border': '0', 'marginTop': '2px', 'marginBottom': '2px', 'padding': '0'});
			cell.appendChild(hr);
			cell = row.insertCell(1);

			for (var j = 0; j < (10/this.minInterval); ++j) {
				row = timeTable.insertRow(rows++);
				for (var i = 0; i < 6; ++i){
					cell = row.insertCell(i);
					cell.className = 'minute';
					cell.width = '14%';
					var minval = ((j*6+i)*this.minInterval);
					if (minval < 10) minval = '0'+minval;
					cell.innerHTML = ':'+minval;
					cell.onclick = this.minuteClickedListener(minval);
					this.minuteCells[(j*6)+i] = cell;
				}
				cell = row.insertCell(i);
				cell.width = '14%';
			}

			row = timeTable.insertRow(rows++);
			cell = row.insertCell(0);
			//cell.className = 'otherminute';
			cell.style.textAlign = 'right';
			cell.colSpan = 5;
			cell.innerHTML = '<i>'+this.tr('Exact minutes')+':</i>';

			cell = row.insertCell(1);
			cell.className = 'otherminute';
			var otherInput = document.createElement('input');
			otherInput.type = 'text';
			otherInput.maxLength = 2;
			otherInput.style.width = '2em';
			var inputTimeout = null;
			otherInput.onkeyup = function(e) {
						if (!isNaN(otherInput.value)) {
							clearTimeout(inputTimeout);
							inputTimeout = setTimeout(function () {
									this.currentDate.setMinutes(otherInput.value);
									this.dateClicked(this.currentDate);
								}.bind(this), 500);
						}
					}.bindAsEventListener(this);
			otherInput.onkeypress = function(e) {
						if (e.keyCode == Event.KEY_RETURN)
							if (this.options.onSelect) this.options.onSelect(this.currentDate);
					}.bindAsEventListener(this);
			// Remove event key capture to allow use of arrow keys
			otherInput.onfocus = this.releaseKeys.bindAsEventListener(this);
			otherInput.onblur = this.captureKeys.bindAsEventListener(this);
			this.otherMinutes = otherInput;
			cell.appendChild(otherInput);
			// Padding cell
			cell = row.insertCell(2);

			row = timeTable.insertRow(rows++);
			cell = row.insertCell(0);
			cell.colSpan = 7;

			hr = document.createElement('hr');
			Element.setStyle(hr, {'color': 'gray', 'backgroundColor': 'gray', 'height': '1px', 'border': '0', 'marginTop': '3px', 'marginBottom': '3px', 'padding': '0'});
			cell.appendChild(hr);

			row = timeTable.insertRow(rows++);
			cell = row.insertCell(0);
			cell.colSpan = 7;

			selectButton = document.createElement('input');
			selectButton.type = 'button';
			selectButton.value = this.tr('Select Date and Time');
			selectButton.onclick = function(e) {
						this.options.onSelect && this.options.onSelect(this.currentDate);
					}.bindAsEventListener(this);
			cell.appendChild(selectButton);

		} else {
			calCont.appendChild(calTable);
		}

		return calCont;

	},
	createCalendar: function(date) {
		this.currentDate = date;
		this.currentDays = [];

		var today = new Date();
		var previousYear = new Date(date.getFullYear() - 1, date.getMonth(), 1)
		var previousMonth = new Date(date.getFullYear(), date.getMonth() - 1, 1)
		var nextMonth = new Date(date.getFullYear(), date.getMonth() + 1, 1)
		var nextYear = new Date(date.getFullYear() + 1, date.getMonth(), 1)

		var row;
		var cell;
		var rows = 0;

		var calTable = document.createElement('table');
		calTable.cellSpacing = 0;
		calTable.cellPadding = 0;
		calTable.border = 0;

		row = calTable.insertRow(rows++);
		row.className = 'monthLabel';
		cell = row.insertCell(0);
		cell.colSpan = 7;
		cell.innerHTML = this.monthName(date.getMonth()) + ' ' + date.getFullYear();

		row = calTable.insertRow(rows++);
		row.className = 'navigation';

		cell = row.insertCell(0);
		cell.className = 'navbutton';
		cell.title = this.monthName(previousYear.getMonth()) + ' ' + previousYear.getFullYear();
		cell.onclick = this.movePreviousYearListener();
		cell.innerHTML = '&lt;&lt;';

		cell = row.insertCell(1);
		cell.className = 'navbutton';
		cell.title = this.monthName(previousMonth.getMonth()) + ' ' + previousMonth.getFullYear();
		cell.onclick = this.movePreviousMonthListener();
		cell.innerHTML = '&lt;';

		cell = row.insertCell(2);
		cell.colSpan = 3;
		cell.className = 'navbutton';
		cell.title = today.getDate() + ' ' + this.monthName(today.getMonth()) + ' ' + today.getFullYear();
		cell.onclick = this.dateClickedListener(today, true);
		if (this.options.timePicker)
			cell.innerHTML = this.tr('Now');
		else
			cell.innerHTML = this.tr('Today');

		cell = row.insertCell(3);
		cell.className = 'navbutton';
		cell.title = this.monthName(nextMonth.getMonth()) + ' ' + nextMonth.getFullYear();
		cell.onclick = this.moveNextMonthListener();
		cell.innerHTML = '&gt;';

		cell = row.insertCell(4);
		cell.className = 'navbutton';
		cell.title = this.monthName(nextYear.getMonth()) + ' ' + nextYear.getFullYear();
		cell.onclick = this.moveNextYearListener();
		cell.innerHTML = '&gt;&gt;';

		row = calTable.insertRow(rows++);
		row.className = 'dayLabel';
		for (var i = 0; i < 7; ++i){
			cell = row.insertCell(i);
			cell.width = '14%';
			cell.innerHTML = this.dayName((this.options.firstWeekDay + i) % 7);
		}
		
		row = null;
		var workDate = new Date(date.getFullYear(), date.getMonth(), 1);
		var day = workDate.getDay();
		var j = 0;

		// Pad with previous month
		if (day != this.options.firstWeekDay) {
			row = calTable.insertRow(rows++);
			row.className = 'calendarRow';
			workDate.setDate(workDate.getDate() - ((day - this.options.firstWeekDay + 7) % 7));
			day = workDate.getDay();
			while (workDate.getMonth() != date.getMonth()) {
				cell = row.insertCell(row.cells.length);
				this.assignDayClasses(cell, 'dayothermonth', workDate);
				cell.innerHTML = workDate.getDate();
				cell.onclick = this.dateClickedListener(workDate);
				workDate.setDate(workDate.getDate() + 1);
				day = workDate.getDay();
			}
		}

		// Display days
		while (workDate.getMonth() == date.getMonth()) {
			if (day == this.options.firstWeekDay) {
				row = calTable.insertRow(rows++);
				row.className = 'calendarRow';
			}
			cell = row.insertCell(row.cells.length);
			this.assignDayClasses(cell, 'day', workDate);
			cell.innerHTML = workDate.getDate();
			cell.onclick = this.dateClickedListener(workDate);
			this.currentDays[workDate.getDate()] = cell;
			workDate.setDate(workDate.getDate() + 1);
			day = workDate.getDay();
		}

		// Pad with next month
		if (day != this.options.firstWeekDay)
			do {
				cell = row.insertCell(row.cells.length);
				this.assignDayClasses(cell, 'dayothermonth', workDate);
				cell.innerHTML = workDate.getDate();
				var thisDate = new Date(workDate.getTime());
				cell.onclick = this.dateClickedListener(workDate);
				workDate.setDate(workDate.getDate() + 1);
				day = workDate.getDay();
			} while (workDate.getDay() != this.options.firstWeekDay);

		return calTable;
	},
	movePreviousMonthListener: function() {
		return function(e) {
				var prevMonth = new Date(
						this.currentDate.getFullYear(),
						this.currentDate.getMonth() - 1,
						this.currentDate.getDate(),
						this.currentDate.getHours(),
						this.currentDate.getMinutes());
				if (prevMonth.getMonth() != (this.currentDate.getMonth() + 11) % 12) prevMonth.setDate(0);
				this.selectDate(prevMonth);
			}.bindAsEventListener(this);
	},
	moveNextMonthListener: function() {
		return function(e) {
				var nextMonth = new Date(
						this.currentDate.getFullYear(),
						this.currentDate.getMonth() + 1,
						this.currentDate.getDate(),
						this.currentDate.getHours(),
						this.currentDate.getMinutes());
				if (nextMonth.getMonth() != (this.currentDate.getMonth() + 1) % 12) nextMonth.setDate(0);
				this.selectDate(nextMonth);
			}.bindAsEventListener(this);
	},
	moveNextYearListener: function() {
		return function(e) {
				var nextYear = new Date(
						this.currentDate.getFullYear() + 1,
						this.currentDate.getMonth(),
						this.currentDate.getDate(),
						this.currentDate.getHours(),
						this.currentDate.getMinutes());
				if (nextYear.getMonth() != this.currentDate.getMonth()) nextYear.setDate(0);
				this.selectDate(nextYear);
			}.bindAsEventListener(this);
	},
	movePreviousYearListener: function() {
		return function(e) {
				var prevYear = new Date(
						this.currentDate.getFullYear() - 1,
						this.currentDate.getMonth(),
						this.currentDate.getDate(),
						this.currentDate.getHours(),
						this.currentDate.getMinutes());
				if (prevYear.getMonth() != this.currentDate.getMonth()) prevYear.setDate(0);
				this.selectDate(prevYear);
			}.bindAsEventListener(this);
	},
	dateClickedListener: function(date, timeOverride) {
		var dateCopy = new Date(date.getTime());
		return function(e) {
				if (!timeOverride) {
					dateCopy.setHours(this.currentDate.getHours());
					dateCopy.setMinutes(this.currentDate.getMinutes());
				}
				this.dateClicked(dateCopy);
			}.bindAsEventListener(this);
	},
	hourClickedListener: function(hour) {
		return function(e) {
				this.hourClicked(hour);
			}.bindAsEventListener(this);
	},
	minuteClickedListener: function(minutes) {
		return function(e) {
				this.currentDate.setMinutes(minutes);
				this.dateClicked(this.currentDate);
			}.bindAsEventListener(this);
	},
	amClickedListener: function() {
		return function(e) {
				if (this.selectedAmPm == this.pmCell) {
					this.currentDate.setHours(this.currentDate.getHours()-12);
					this.dateClicked(this.currentDate);
				}
			}.bindAsEventListener(this);
	},
	pmClickedListener: function() {
		return function(e) {
				if (this.selectedAmPm == this.amCell) {
					this.currentDate.setHours(this.currentDate.getHours()+12);
					this.dateClicked(this.currentDate);
				}
			}.bindAsEventListener(this);
	},
	assignDayClasses: function(cell, baseClass, date) {
		var today = new Date();
		Element.addClassName(cell, baseClass);
		if (date.getFullYear() == today.getFullYear() && date.getMonth() == today.getMonth() && date.getDate() == today.getDate())
			Element.addClassName(cell, 'today');
		if (this.options.weekend.include(date.getDay()))
			Element.addClassName(cell, 'weekend');
	},
	monthName: function(month) {
		return this.options.months[month];
	},
	dayName: function(day) {
		return this.options.days[day];
	},
	dblClickHandler: function(e) {
		if(this.options.onSelect)
			this.options.onSelect(this.currentDate);
		Event.stop(e);
	},
	clickHandler: function(e) {
		if(this.options.onClick)
			this.options.onClick();
		Event.stop(e);
	},
	hoverHandler: function(e) {
		if(this.options.onHover)
			this.options.onHover(date);
	},
	keyHandler: function(e) {
		var days = 0;
		switch (e.keyCode){
			case Event.KEY_RETURN:
				if (this.options.onSelect) this.options.onSelect(this.currentDate);
				break;
			case Event.KEY_LEFT:
				days = -1;
				break;
			case Event.KEY_UP:
				days = -7;
				break;
			case Event.KEY_RIGHT:
				days = 1;
				break;
			case Event.KEY_DOWN:
				days = 7;
				break;
			case 33: // PgUp
				var lastMonth = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth() - 1, this.currentDate.getDate());
				days = -this.getDaysOfMonth(lastMonth);
				break;
			case 34: // PgDn
				days = this.getDaysOfMonth(this.currentDate);
				break;
			case 13: // enter-key (forms without submit buttons)
				this.dateClicked(this.currentDate);
				break;
			default:
				return;
		}
		if (days != 0) {
			var moveDate = new Date(this.currentDate.getFullYear(), this.currentDate.getMonth(), this.currentDate.getDate() + days);
			moveDate.setHours(this.currentDate.getHours());
			moveDate.setMinutes(this.currentDate.getMinutes());
			this.selectDate(moveDate);
		}
		Event.stop(e);
		return false;
	},
	getDaysOfMonth: function(date) {
		var lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
		return lastDay.getDate();
	},
	getNextMonth: function(month, year, increment) {
		if (p_Month == 11) return [0, year + 1];
		else return [month + 1, year];
	},
	getPrevMonth: function(month, year, increment) {
		if (p_Month == 0) return [11, year - 1];
		else return [month - 1, year];
	},
	dateClicked: function(date) {
		if (date) {
			if (!this.options.timePicker && this.options.onSelect)
				this.options.onSelect(date);
			this.selectDate(date);
		}
	},
	hourClicked: function(hour) {
		if (hour == 12) {
			if (this.selectedAmPm == this.amCell)
				hour = 0;
		} else if (this.selectedAmPm == this.pmCell) {
			hour += 12;
		}
		this.currentDate.setHours(hour);
		this.dateClicked(this.currentDate);
	},
	selectDate: function(date) {
		if (date) {
			if (date.getMonth() != this.currentDate.getMonth()
					|| date.getFullYear() != this.currentDate.getFullYear())
				this.setDate(date);
			else
				this.currentDate = date;

			if (date.getDate() < this.currentDays.length) {
				if (this.selectedDay)
					Element.removeClassName(this.selectedDay, 'current');
				this.selectedDay = this.currentDays[date.getDate()];
				Element.addClassName(this.selectedDay, 'current');
			}

			if (this.options.timePicker) {
				var hours = date.getHours();
				if (this.selectedHour)
					Element.removeClassName(this.selectedHour, 'current');
				this.selectedHour = this.hourCells[hours % 12 ? (hours % 12) - 1 : 11];
				Element.addClassName(this.selectedHour, 'current');

				if (this.selectedAmPm)
					Element.removeClassName(this.selectedAmPm, 'current');
				this.selectedAmPm = (hours < 12 ? this.amCell : this.pmCell);
				Element.addClassName(this.selectedAmPm, 'current');

				var minutes = date.getMinutes();
				if (this.selectedMinute)
					Element.removeClassName(this.selectedMinute, 'current');
				Element.removeClassName(this.otherMinutes, 'current');
				if (minutes % this.minInterval == 0) {
					this.otherMinutes.value = null;
					this.selectedMinute = this.minuteCells[minutes / this.minInterval];
					Element.addClassName(this.selectedMinute, 'current');
				} else {
					this.otherMinutes.value = minutes;
					Element.addClassName(this.otherMinutes, 'current');
				}
			}

			if (this.options.onHover)
				this.options.onHover(date);
		}
	}
});
