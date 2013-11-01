# = EventConnector
# 
# This module is meant to make it easier to connect ruby methods to
# WxWidgets events generated by user interaction. It introduces a
# consistent syntax for linking events to handlers, using the +listen+
# method:
#
#  listen(evt, source, handler) { block }
# 
# The parameter +evt+ is the type of event that should be listened for,
# for example the click of a button. To ask to listen to 'click' events,
# pass the argument +:click+
#
# The parameter +source+ is the widget whose events should be listened
# for. This might be a particular button. If +source+ is set to *nil*,
# and lots of widgets might generate this kind of event (for example, if
# you have multiple buttons), it assumes that *ANY* button's clicking
# should be handled.
# 
# The final part of dealing with user events is specifying what should
# be done when the event occurs. One way is to pass the +handler+
# argument, which should be the name of a method (as a string or symbol)
# which will handle the event. The other way is to pass a block which
# should be called when the event is triggered.
# 
# This handling method or block may, optionally, accept a single
# argument, which will be the Event object generated by the event.
# 
# == Explanation
#
# This module is meant to take some of the pain out of hooking up event
# handlers to objects. There are subtle differences in WxWidgets in how
# different types of events are passed to widgets. Some events
# (typically those fired by controls, subclasses of +CommandEvent+) are
# passed upwards to any containing window that is interested. Others,
# WxWidgets assumes, are only of interest to the window that generates
# the event: most events related to frames (ActivateEvent, for example)
# and miscellaneous windows (Sashes, ScrollWindows) fall under this
# category.
module EventConnector
  module ClassMethods
    def event_hooks()
      @__ehooks__ ||= {} 
    end

    # look out for on_xxx methods being added, so they can be hooked up
    # automatically when instances of this widget are created
    def method_added(name)
      if name.to_s =~ /^on_(.*)/
        event_hooks[$1.intern] = name
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
    # need a general way to safely interpose in Module methods
  end

  # Listen to events of type +evt+ (eg. 'click', 'mousedown'), on the
  # widget +source+, and handle it by +handler+ or +block+
  # The handling code can be specified in a number of different ways:
  # If neither +handler+ or +block+ is passed, then the method will
  # attempt to attach events to a listener method called "on_EVT", where
  # EVT is 'click', 'mousedown' etc). 
  # 
  #  listen(:click, my_button) # assumes on_click is defined
  # 
  # If handler is specified as a symbol, the listener will call this
  # named method when the event is triggered
  # 
  #  listen(:click, my_button, :on_click_my_button)
  #
  # If a block is passed, it will be run when the event is triggered.
  # 
  #  listen(:click, my_button) { p "click my button" }
  # 
  # Methods or blocks that are defined as handlers may optionally
  # receive one argument, the Wx event object (see the WxWidgets documentation
  # for more details on this object):
  # 
  #  listen(:checkbox, my_checkbox) { | e | puts e.is_checked }
  # 
  # Or in a handler method:
  #
  #  def on_checkbox(e)
  #    if e.is_checked
  #      puts "The checkbox is now checked"
  #    end
  #  end
  #
  def listen(evt, source = self, handler = nil, &block)
    warn "listen is deprecated, use evt_xxx directly (#{caller[0]})"

    # get the WxWidget evt_xxx method that will be called for binding
    event = "evt_#{evt}"
    if self.respond_to?(event)
      # try to bind to recipient's methods
      evt_meth = method(event)
    elsif source and source.respond_to?(event)
      evt_meth = source.method(event)
    else
      Kernel.raise NameError,
                   "Widget #{self} doesn't generate events of type '#{evt}'"
    end

    # get the block or method that will handle the event
    begin
      if block
        handler_meth = block
      elsif handler
        handler_meth = self.method(handler)
      else
        handler ||= "on_#{evt}"
        handler_meth = self.method(handler)
      end
    rescue NameError
      Kernel.raise NameError, "#{self} has no handler #{handler}"
    end

    # Optionally allow block or handler methods to receive the event
    # object as an argument
    if handler_meth.arity == 0
      proc = lambda { handler_meth.call() }
    else
      proc = lambda { | e | handler_meth.call(e) }
    end


    if source
      source_id = source.get_id
    else
      source_id = -1
    end

    begin
      # Some WxWidgest event connector methods expect the ID of the
      # triggering widget, others don't. So we try both ways to hide
      # this complexity
      evt_meth.call( source_id, &proc )
    rescue ArgumentError
      # Try with no ID specified.
      evt_meth.call( &proc )
    end
  end

  # TODO - not called - needs to be done by redefining new
  def initialize(*args)
    super(*args)
    self.class.event_hooks.each do | sym, handler |
      listen(self, sym, handler)
    end
  end
end

class Wx::EvtHandler
  include EventConnector
end
