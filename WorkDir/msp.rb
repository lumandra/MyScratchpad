
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: msp.xrc 
# Generated at: 2013-07-10 08:13:52 +0400

class MyScratchpad < Wx::Frame
	
	attr_reader :m_panel3, :m_button7, :search_ctrl, :m_listbox1,
              :m_button22, :m_button23, :m_button20, :m_button21,
              :m_choicebook3, :m_treectrl, :m_statictext1,
              :add_section_ctrl, :add_section, :m_statictext2,
              :m_statictext7, :add_to_subvol, :m_statictext5,
              :m_textctrl13, :add_new_note, :m_statusbar1, :m_hyperlink1,
              :m_button15, :m_button16,
              :m_menubar1, :file, :load, :save, :savef, :save_as,
              :on_about,
              :exit, :help, :tutorial, :about, :about_app
	
	def initialize(parent = nil)
		super()
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load("msp.xrc")
		xml.load_frame_subclass(self, parent, "MyFrame1")

		finder = lambda do | x | 
			int_id = Wx::xrcid(x)
			begin
				Wx::Window.find_window_by_id(int_id, self) || int_id
			# Temporary hack to work around regression in 1.9.2; remove
			# begin/rescue clause in later versions
			rescue RuntimeError
				int_id
			end
		end
		@m_panel3 = finder.call("m_panel3")
		@m_button7 = finder.call("m_button7")
		@search_ctrl = finder.call("search_ctrl")
		@m_listbox1 = finder.call("m_listBox1")
		@m_button22 = finder.call("m_button22")
		@m_button23 = finder.call("m_button23")
		@m_button20 = finder.call("m_button20")
		@m_button21 = finder.call("m_button21")
        @m_button15 = finder.call("m_button15")
		@m_button16 = finder.call("m_button16")
		@m_choicebook3 = finder.call("m_choicebook3")
		@m_treectrl = finder.call("m_treeCtrl")
		@m_statictext1 = finder.call("m_staticText1")
		@add_section_ctrl = finder.call("add_section_ctrl")
		@add_section = finder.call("add_section")
		@m_statictext2 = finder.call("m_staticText2")
		@m_statictext7 = finder.call("m_staticText7")
		@add_to_subvol = finder.call("add_to_subvol")
		@m_statictext5 = finder.call("m_staticText5")
		@m_textctrl13 = finder.call("m_textCtrl13")
		@add_new_note = finder.call("add_new_note")
		@m_statusbar1 = finder.call("m_statusBar1")
        @m_hyperlink1 = finder.call("m_hyperlink1")
		@m_menubar1 = finder.call("m_menubar1")
		@file = finder.call("File")
		@load = finder.call("Load")
		@save = finder.call("Save")
		@savef = finder.call("Savef")
		@save_as = finder.call("Save_as")
		@exit = finder.call("Exit")
		@help = finder.call("Help")
		@tutorial = finder.call("Tutorial")
		@about = finder.call("About")
		@about_app = finder.call("About_app")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


