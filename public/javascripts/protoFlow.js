/*
Copyright (c) 2008 DeenSoft.com - You are free to use this file wherever you wish but please do let us know at blog.deensoft.com 
so that we can showcase it. You can even post your bugs on our blog and we will fix them asap.

This code is being release under open-terms. Use at your own risk. Give us feedback. Help us fix bugs and implement new features. :)

contact@deensoft.com

There are three ideas in the code.

First, the use of setTimeout to perform animation. setTimeout schedules a function call to occur at some time in the future. If the animation is not yet finished, this function should again call setTimeout.

Second, the math behind the manipulation of the images. The path is a 100-unit hyperbola, where the observer is standing 100 diagonal units away from the origin. Divide the image height by the perpendicular distance from the observer to simulate vanishing. Change the zIndex to simulate occlusion.

Third, the use of hidden div tags to hold data. Set the inner text of a visible div tag to the inner text of a hidden one in order to place the data on the screen.

Enjoy!
------------------------------------------------------------------------------------------------------------------------------

Class: ProtoFlow

Description: 
ProtoFlow v0.5 is a very early preview release that simulates Apples CoverFlow effect using Prototype/Scriptaculous lib.

(code)
var myFlow = new ProtoFlow(
					$('myElem'), 
					{
						captions: 'captionsList'
					}
);
(end)


*/

/*
    * use alt property for caption instead of a separate list
    * now you can pass either an element or an id
    * some refactoring to handleClick
*/
var ProtoFlow = Class.create({
  /*
	Function: initialize

	Description: Constructor for ProtoFlow Class. 

	Parameters:

	elem {Mixed} the HTML object that ProtoFlow is initialize from. This can be either an HTML Object or ID to an HTML object
	opt {Object} config Object
  */
  initialize: function(elem, opt) {
	opt = opt || {}
	this.options = {
		startIndex: 2,
		interval: 60,
		slider: true, 
		flex: 100,
		captions: false,
		autoplay: false,
		autoplayInterval: 5,
        useCaptions: false,
        useReflection: false,
        afterSlide: Prototype.emptyFunction
	},
	Object.extend(this.options, opt);

	if (!$(elem))
        return;
        
	this.elem = $(elem);
	

	
	this.elem.setStyle({overflow: "hidden", position: "relative"});
	this.stack = this.elem.childElements();
    
	this.stackCount = (this.stack).size();

    

	if(this.options.useCaptions)
	{
		this.loadCaptions();
        this.captionHolder = new Element('div');
		this.captionHolder.className = "captionHolder";
		this.captionHolder.setStyle({
			width: "100%",
			textAlign: "center",
			position: 'absolute',
			left: "0px",
			top: (Element.getHeight(this.elem) - 80) + "px"
		});
		this.elem.appendChild(this.captionHolder);
	}

	this.loadReflection();
	
	this.currPos = this.options.startIndex - 1;
	this.currIndex = this.currPos;
	/* slider */
	if(this.options.slider)
	{
		this.sliderContainer = new Element('div');
		this.sliderContainer.setStyle({
			width: '200px',
			height: '10px',
			position: 'absolute',
			top: (this.elem.getHeight() - 30) + "px",
			left: (this.elem.getWidth() / 2  - (137/2)) + "px"
		});
		
		this.sliderTrack = new Element('div');
		this.sliderTrack.className = "sliderTrack";

		this.sliderHandle = new Element('div');
		this.sliderHandle.className = "sliderHandle";
		
		this.sliderTrack.appendChild(this.sliderHandle);
		this.sliderContainer.appendChild(this.sliderTrack);

		this.elem.appendChild(this.sliderContainer);

		this.slider = new Control.Slider(this.sliderHandle, this.sliderTrack, {
			range: $R(0, this.getStackCount() - 1),
			sliderValue: this.getCurrentPos(), // won't work if set to 0 due to a bug(?) in script.aculo.us
			onSlide: this.handleSlider.bind(this),
			onChange: this.handleSlider.bind(this)
		});
	}



	this.timer = 0;
	 
	
	/* sets up click listener on all the elements in the stack */
	this.stack.each(function(elem){
			elem.observe('click', this.handleClick.bind(this));
	}.bind(this));

	
	this.goTo(this.currPos);
	
	this.autoplayer = null;
	if(this.options.autoplay)
	{
		this.autoplayer = new PeriodicalExecuter(this.autoPlay.bind(this), this.options.autoplayInterval);
	}

	Event.observe(window, 'resize', this.handleWindowResize.bind(this));
  },
  
  
  /*
      Grab captions from alt of images  
  */
  loadCaptions: function(){
      this.captions = this.stack.pluck("alt");
      this.captionsCount = this.captions.size();
  },
  
  
  loadReflection: function(){
      if (this.options.useReflection)
      {
          this.stack.each(function(elt){ Reflection.add(elt, {opacity: 2/3})})
          this.stack  = this.stack.map(function(e){ return e.up("div)")});
          this.stack.invoke("identify");
      }
          
  },
  
  autoPlay: function(){
	  if((this.currIndex + 2) > this.stackCount)
	  {
		  this.currIndex = 0;
	  }
	  this.currIndex = this.currIndex + 1
	  this.goTo();
  },
  
  handleWindowResize: function(event)
  {
  },
  
  handleWheel: function(event)
  {
	v = Event.wheel(event);
	this.goTo(this.currIndex + v);
	this.slider.setValue(this.currIndex + v);
  },
  
  handleSliderChange: function(v) {
	
	this.goTo(v);
  },
  
  handleSlider: function(v){
	if(v)
    {
      this.currIndex = v;
      this.goTo();  
    } 
        
  },
  
  handleClick: function(e)
  {
	this.lastClickedElement = e.element();
    if(this.options.useReflection) { this.lastClickedElement = this.lastClickedElement.up('div'); }
    this.currIndex = this.lastClickedElement.getAttribute("index");
	this.goTo();
	this.updateSlider();
  },
  
  getCurrentPos: function()
  {
	return this.currPos;
  },
  
  goTo: function(index)
  {
	this.slideTo(this.currIndex * this.options.flex * -1);
	if(this.options.useCaptions) {
		this.captionHolder.update(this.captions[Math.round(this.currIndex)]);
	}
    this.options.afterSlide(this.lastClickedElement);
  },
  
  updateSlider: function(index)
  {
	if(this.options.slider) 
        this.slider.setValue(this.currIndex);
  },
  
  step: function()
  {
	if(this.target < this.currPos - 1 || this.target > this.currPos + 1)
	{
		this.moveTo(this.currPos + (this.target-this.currPos)/5);
		window.setTimeout(this.step.bind(this), this.options.interval);
		this.timer = 1;
	}
	else
	{
		this.timer = 0;

	}
  },
  
  slideTo: function(x)
  {
	this.target = x;
	
	if(this.timer == 0)
	{
		window.setTimeout(this.step.bind(this), this.options.interval);
		this.timer = 1;
	}

	
  },

  moveTo: function(currentPos)
  {
	 var x = currentPos;
	 this.currPos = currentPos;
	 var width = this.elem.getWidth();
	 var height = this.elem.getHeight();

	 var top = this.elem.offsetTop;
	 var size = width * 0.5;
	 var biggest = height;
	 var zIndex = this.stackCount;
	(this.stack).each((
					function(elem, index) {
						
						Element.absolutize(elem);
						elem.setAttribute("index", index);
						var z = Math.sqrt(10000 + x * x * 1) + 100;
						var xs = x / z * size + size;
						elem.setStyle({
							left: (xs - 40 / z * biggest) + "px",
							top: (30 / z * size + 0) + "px"/*,
                            width:(100 / z * biggest) + "px",
							height: (110.25 / z * biggest) + "px"*/
			
						});
						//console.log(elem);
						elem.style.zIndex = zIndex;
						
						if(x < 0)
							zIndex++;
						else 
							zIndex--;
						x += this.options.flex;

					}
				).bind(this));
  },

  getStackCount: function()
  {
	return this.stackCount;
  }
});