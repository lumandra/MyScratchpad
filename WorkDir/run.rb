require 'wx'
require 'yaml'
require 'ya2yaml'
require 'unicode'
require 'fileutils'
require_relative 'msp.rb'
require_relative 'tree.rb'
require_relative 'choicebook.rb'
require_relative 'modal.rb'
 
class RubyMainFrame < MyScratchpad
  include Tree
  include Choicebook
  include ModalMessages
  def initialize
    super
    ##
    ##open or create project(enter name, create dir, nessar files and open project)
    open_project
    setup_menus
	#construction of the tree
    build_tree
    build_choicebook()
	evt_button(add_section){ addSection }
    evt_tree_sel_changed (m_treectrl) {| event | item_click }
    evt_button(add_new_note){ add_subvol_to_file }  
    evt_button(m_button7){ search }
    evt_listbox(m_listbox1) { | event | get_search_result }
    evt_button(m_button22){ editSection }
    evt_button(m_button23){ deleteSection }
    evt_button(m_button21){ editNote }
    evt_button(m_button20){ deleteNote }
    evt_button(m_button16){ clearFormAdd }
    evt_button(m_button15){ addSeparator }
    evt_hyperlink(m_hyperlink1) { | event | help_move_section }
    evt_close() { | event | is_synch? }
    #hotkey global registry
	#self.RegisterHotKey(106, Wx::MOD_ALT, Wx::K_F1)
	#evt_hotkey 106, :from_clipboard
  end  
  ##
  Clipboard_add = 100
  Clipboard_on = 106
  Synch_to = 101
  Open_project = 103
  New_project = 104
  Remove_project = 105
  #$current_project = "ROOT"
  #$curent_item = $current_project
  $section_edit = "OFF"
  $note_edit = "OFF"
  $old_label = ""
  $old_label_id = ""
  ###########################################################################################################################
  #MENU######################################################################################################################
  def setup_menus
    menu_file = Wx::Menu.new()
    menu_clipbrd = Wx::Menu.new()
    menu_help = Wx::Menu.new()
    # in the correct platform-specific place
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about programm")
    menu_file.append(New_project, "&New project...\tCtrl-N", "New Project")
    menu_file.append(Open_project, "&Open project...\tCtrl-O", "Open Project")
    menu_file.append(Remove_project, "&Manager for delete project...\tCtrl-R", "Delete Project")
    menu_file.append(Synch_to, "&Remote synch...\tCtrl-S", "Remote synchronization with project")
    menu_file.append(Wx::ID_PRINT, "&Print...\tCtrl-P", "Print current note")
    menu_clipbrd.append(Clipboard_add, "&From clipboard...\tShift-F1", "Get selected text from the clipboard")
    menu_clipbrd.append_check_item(Clipboard_on,  "&Switch global key for clipboard...\tShift-F1-Enter", "Switch global key for clipboard")
    menu_file.append_menu(Wx::ID_ANY, "From clipboard menu", menu_clipbrd, "Clipboard menu")
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar = Wx::MenuBar.new()
    menu_bar.append(menu_file, "&File")
    menu_bar.append(menu_help, "&Help")
    # Assign the menus to this frame
    self.menu_bar = menu_bar
    # menu events
    evt_menu Wx::ID_ABOUT, :on_about
    evt_menu New_project, :new_project
    evt_menu Open_project, :open_project
    evt_menu Remove_project, :remove_project
    evt_menu Synch_to, :synch_to
    evt_menu Wx::ID_PRINT, :on_print
    evt_menu Clipboard_add, :from_clipboard
    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Clipboard_on, :switch_glb_clipbr
  end
  
  def on_about
   text = " " * 35 + "MyScratchpad(free version)\n\n" + 
   "This program is designed to help people to take notes in different areas of life. Students will find this program useful for learning. For example, if you study any science or profession will be completely need
   structure their knowledge. For this purpose there is a tree of sections in which you can build yourself comfortable for sections of the studied material. The same is present functionality quickly saving notes from the clipboard of the operating system('From clipboard' Shift-F1), for example if you study a resource you can quickly save the key points and then to analyze and sort them.
   You are using the free version of the program.
   Such functionality as:
   - printing notes;
   - synchronization through a single repository on the Internet your notes;
   - golobalnoy-use keys to the clipboard (When the application runs in the background and you select the text to save it to your notes, you can not opening the app to save a note)
   only available in the comercial version.
   
   The author of this program is the Russian developer Artem Pecherin(bizzon-app.com)."

   dialogMultLines(text, "About programm", Wx::ICON_INFORMATION)
  end
  
  def new_project
    new_project = dialogTextEntry("Please entry name for new project", "New project in MyScratchpad")
    if (new_project == nil && Dir["#{Dir.pwd}/Projects/*"].empty?)
      dialogMultLines("You can not start to use the program without creating any project", "Open error", Wx::ICON_ERROR)
      return close
    elsif new_project == nil
      return
    else
      $curent_item = $current_project = new_project.to_s.upcase!
      if $current_project == nil 
        $curent_item = $current_project = new_project
      end
      #add new projects to list
      if File.exist?('./Projects/projects.yml')
        projects = YAML::load(open("#{Dir.pwd}/Projects/projects.yml"))
        projects[$current_project] = ["none"] 
      else
        projects = Hash.new(0)
        projects[$current_project] = ["none"] 
      end
      #$curent_item = $current_project
      FileUtils.mkpath "#{Dir.pwd}/Projects/#{$current_project}"
      #create tree
      tree = Hash.new(0)
      tree[$current_project] = Hash.new(0)
      tree[$current_project]["CLIPBOARD"] = Hash.new(0)
      #subvols
      subvols = Hash.new(0)
      subvols[$current_project] = ["none"]
      subvols["CLIPBOARD"] = ["none"]
      #subvols_note
      subvols_note = Hash.new(0)
      subvols_note[$current_project] = Hash.new(0)
      subvols_note["CLIPBOARD"] = Hash.new(0)
      subvols_note[$current_project]['none'] = ['none']
      subvols_note["CLIPBOARD"]['none'] = ['none']
      ##save
      File.open("#{Dir.pwd}/Projects/#{$current_project}/tree.yml", 'w:UTF-8') {|f| f.write(YAML::dump(tree))}
      File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols))}
      File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols_note))}
      File.open("#{Dir.pwd}/Projects/projects.yml", 'w:UTF-8') {|f| f.write(YAML::dump(projects))}
      build_tree
      build_choicebook()
    end
  end
  
  def open_project
    if Dir["#{Dir.pwd}/Projects/*"].empty?
      on_about
      new_project
    else
      projects = YAML::load(open("#{Dir.pwd}/Projects/projects.yml"))
      answer = dialogChoice("Choose project for using:", "Choose project in MyScratchpad", projects.keys, "You use next project:", "Current project")
      if answer 
        $curent_item = $current_project = answer
        build_tree
        build_choicebook()
      elsif !answer && $current_project == nil
        dialogMultLines("You can not start to use the program without choosing the project", "Open error", Wx::ICON_ERROR)
        close
      else  
        return
      end      
    end
  end
  
  def remove_project
    projects = YAML::load(open("#{Dir.pwd}/Projects/projects.yml"))
    if projects.keys.length == 1
      return dialogMultLines("Please add the new project because it is one you.\n" + "After that, you can delete the current project.", "Remove error", Wx::ICON_ERROR)
    end
    answer = dialogChoice("Choose project for delete:", "Manager for delete project", projects.keys, "You choose next project for remove:", "Project for remove")
    if answer == $current_project
      return dialogMultLines("You can not delete the current project. You using this project now. Please open another project, run 'Manager for delete project' and remove this project", "Remove error", Wx::ICON_ERROR)
    end
    if !dialogConfirmAction?("ATTENTION! Do you want to delete the project #{answer}? ALL data will delete. Also ALL sections and notes will delete. Please confirm.","Confirm delete", Wx::ICON_QUESTION)
      return 
    else
      if !dialogConfirmAction?("ATTENTION! Do you want to delete the project #{answer}? Are sure??","Confirm delete", Wx::ICON_QUESTION)
        return
      else
        #remove project...
        #remove from list
        projects = YAML::load(open("#{Dir.pwd}/Projects/projects.yml")) 
        projects.delete(answer)
        File.open("#{Dir.pwd}/Projects/projects.yml", 'w:UTF-8') {|f| f.write(YAML::dump(projects))}
        #remove files
        FileUtils.rm_r "./Projects/#{answer}"
        return dialogMultLines("The project #{answer} has been deleted", "Manager for delete project", Wx::ICON_INFORMATION)
      end
    end
  end
  
  def synch_to
    return dialogMultLines("Sorry, but this functionality is not working in free version", "Synchronization error", Wx::ICON_ERROR)
  end
  
  def on_print
    return dialogMultLines("Sorry, but this functionality is not working in free version", "Print error", Wx::ICON_ERROR)
  end
  
  def switch_glb_clipbr 
    return dialogMultLines("Sorry, but this functionality is not working in free version", "Global key mode for copy from clipboard error", Wx::ICON_ERROR)
  end
  
  def from_clipboard
    #set current section- CLIPBOARD
    m_treectrl.select_item($tree_label_id['CLIPBOARD'])
    add_to_subvol.clear
    m_textctrl13.clear
    time = Time.new.strftime("%d%H%M%S")
    add_to_subvol.set_value("Note#{time}")
    #geting text from clipboard
    Wx::Clipboard.open do |clip|
      if clip.supported?(Wx::DF_TEXT)
        txt = Wx::TextDataObject.new
        clip.get_data(txt)
        m_textctrl13.set_value(txt.text)
      end
      add_subvol_to_file
    end
  end
  
  def on_quit
    close
  end
  #############################################################################################################################
  def help_move_section
    text = "If you want to move the current note from current section under another section follow these simple steps:
    1. Click button to edit the note('Edit note'). The title and text of the selected note is moved to the appropriate fields in the form to save a new note.
    2. Next, select the desired section in tree of the sections in which you want to move a note.
    3. Click button to save the note('Save note'). Note is automatically removed from the old section and added a new section."
    dialogMultLines(text, "Move help", Wx::ICON_INFORMATION)
  end
  
  def item_click
	cur_sel_lbl = m_treectrl.get_item_text(m_treectrl.get_selection())
    $curent_item = cur_sel_lbl
    build_choicebook()
  end
  
  def addSection
    if $section_edit == "ON"
      return editSection
    end
	if (!add_section_ctrl.value.to_s.empty?)
      n_section = add_section_ctrl.value
      n_section = Unicode::upcase(n_section)
      if (!check_section?(n_section))
        cur_sel = m_treectrl.get_selection()
	    cur_sel_lbl = m_treectrl.get_item_text(cur_sel)
        #add to tree and add to file
        cnt_and_get_parents(cur_sel, cur_sel_lbl)
        if (add_tree_to_file($parents_arr, n_section))
          m_treectrl.append_item(cur_sel, n_section)
          addToSubvol(n_section)
          build_tree(n_section)
        end
      else
        ##error dialog
        return dialogMultLines("Please enter another name of section term. This name is already present", "Save error", Wx::ICON_ERROR)
      end
    else
      ##error dialog
      return dialogMultLines("Please enter a new section term", "Save error", Wx::ICON_ERROR)
	end
	add_section_ctrl.clear
  end
   
  def cnt_and_get_parents(cur_id, cur_lb)
    parent_id = m_treectrl.get_item_parent(cur_id)
    parent_lb = m_treectrl.get_item_text(parent_id)    
    $parents_arr = Array.new()
    i = 0
    loop do
      if i == 0 && !parent_lb.empty?
        $parents_arr.unshift(parent_lb)
      end  
      i = i + 1
      parent_id = m_treectrl.get_item_parent(parent_id)
      parent_lb = m_treectrl.get_item_text(parent_id) 
      if !parent_lb.empty?     
        $parents_arr.unshift(parent_lb)
      end    
      break if ((i==7) || parent_lb.empty?)
    end
    return $parents_arr << cur_lb
  end
  
  def search
    m_listbox1.clear
    #get search item
    if search_ctrl.is_empty()
      #message error
      return dialogMultLines("Please enter a search term", "Search error", Wx::ICON_ERROR)
    end
    search_v = search_ctrl.get_value.to_s
    $notes = search_note(search_v)
    if $notes.empty? 
      #message error
      search_ctrl.clear
      return dialogMultLines("Input term #{search_v} not found in the #{$curent_item} section and in her subsections(recursive search). Try to expand search.", "Search result", Wx::ICON_INFORMATION)
    end
    $notes.each do |section, notes|
      notes.each do |title, text|
          text = text.ya2yaml(:syck_compatible => true)
          text = (text.rindex('|-') == nil ? text.slice(7, 9999*9999) : text.slice(14, 9999*9999))
          index = text.index(search_v, 1) != nil  ? text.index(search_v, 1) : 0
          #"abcd".insert(0, 'X')    #-> "Xabcd"
          #a.slice(1..3)                #-> "ell"
          text = text.slice(index < 15 ? index  : index - 15, search_v.length + 100).insert(0, '...').insert(-1, '...')  
          sepa = "." * 100
          to_list = "#{text} #{sepa} Section:#{section}, Note: #{title}"
          m_listbox1.insert_items([to_list], 0)
      end
    end
  end
  
  def get_search_result
    build_tree
    str = m_listbox1.get_string_selection
    sects1 =  str.slice(str.rindex("Section:") +8, 50) 
    nots = str.slice(str.rindex("Note:"), 50)
    sects1.slice!(", " + nots)
    m_treectrl.select_item($tree_label_id[sects1])
    nots.slice!("Note: ")
    n_position = get_index_item(sects1, nots)
    m_choicebook3.set_selection(n_position - 1)
  end
  
  def editSection
    if $section_edit == "OFF"
	  cur_sel = m_treectrl.get_selection()
	  cur_sel_lbl = m_treectrl.get_item_text(cur_sel)
      if ((cur_sel_lbl == $current_project) || (cur_sel_lbl == $current_project))
        return dialogMultLines("This section #{cur_sel_lbl} not allowed to edit. This nodes of system.", "Edit error", Wx::ICON_ERROR)
      else
        if !dialogConfirmAction?("Do you want to edit the name of the section #{cur_sel_lbl}? Please confirm. The name of this section will appear in the field to be saved. Just edit and click 'Save'.","Confirm edit", Wx::ICON_QUESTION)
          return 
        end
        add_section_ctrl.set_value(cur_sel_lbl)
        $old_label = cur_sel_lbl
        $old_label_id = cur_sel
        #set global flag that section editing
        return $section_edit = "ON"
      end
    end  
    #edit in DB and rebuild tree with new item
    n_section = Unicode::upcase(add_section_ctrl.value)
    n_section == $old_label ? (dialogMultLines("You have not entered the new name for the section #{cur_sel_lbl}. There was no change.", "Edit error", Wx::ICON_ERROR)) : delete_edit_section(n_section, $old_label, $old_label_id, "edit")     
    #of global flag that section edited
    add_section_ctrl.clear
    $section_edit = "OFF"
  end
  
  def deleteSection
    $old_label_id = m_treectrl.get_selection()
	$old_label = m_treectrl.get_item_text($old_label_id)
    if (($old_label == $current_project) || ($old_label == "CLIPBOARD"))
      return dialogMultLines("This section #{$old_label} not allowed to remove. This nodes of system.", "Delete error", Wx::ICON_ERROR)
    else
      if !dialogConfirmAction?("ATTENTION! Do you want to delete the section #{$old_label}? ALL subsection of #{$old_label} are as will delete. Also ALL notes there sections are as will delete. Please confirm.","Confirm delete", Wx::ICON_QUESTION)
        return 
      end
      delete_edit_section(nil, $old_label, $old_label_id, "delete")  
    end  
  end
  
  def editNote
    if $note_edit == "OFF"
        $n_posit = m_choicebook3.get_selection()
        cur_sel_lbl = m_treectrl.get_item_text(m_treectrl.get_selection())
        title = m_choicebook3.get_page_text($n_posit)
        text = get_text_for_title(cur_sel_lbl, title)
        if title == "none"
          return dialogMultLines("This note not allowed to edit. This nodes of system.", "Edit error", Wx::ICON_ERROR)
        else
          if !dialogConfirmAction?("Do you want to edit the notes #{title}? Please confirm. The title and text of this note will appear in the field to be saved. Just edit and click 'Save note'.","Confirm edit", Wx::ICON_QUESTION)
            return 
          end
          add_to_subvol.set_value(title)
          m_textctrl13.set_value(text)        
          $label = cur_sel_lbl
          $old_title = title
          $old_text = text
          #set global flag that section editing
          return $note_edit = "ON"
        end
    end  
    #determine what has changed => determine logic
    new_title = add_to_subvol.value
    new_text = m_textctrl13.value
    if ($old_text == new_text && $old_title == new_title && $label == m_treectrl.get_item_text(m_treectrl.get_selection()))  
      add_to_subvol.clear
      m_textctrl13.clear
      $note_edit = "OFF"
      return dialogMultLines("There were no changes during editing.", "Save error", Wx::ICON_ERROR)    
    else
      puts "BEGIN1"
      #remove old title in subvols.yml
      remove_title($label, $old_title)
      #remove old title and text in subvols_note.yml
      remove_text_title($label, $old_title)
    end
    #of global flag that section edited
    $note_edit = "OFF"
    add_subvol_to_file()
  end
  
  def deleteNote
    cur_sel_lbl = m_treectrl.get_item_text(m_treectrl.get_selection())
    title = m_choicebook3.get_page_text(m_choicebook3.get_selection())
    text = get_text_for_title(cur_sel_lbl, title)
    if title == "none"
      return dialogMultLines("This note not allowed to remove. This nodes of system.", "Edit error", Wx::ICON_ERROR)
    else
      if !dialogConfirmAction?("ATTENTION! Do you want to delete the note #{title}? Please confirm.","Confirm delete", Wx::ICON_QUESTION)
        return 
      end
      remove_title(cur_sel_lbl, title)
      #remove old title and text in subvols_note.yml
      remove_text_title(cur_sel_lbl, title)
    end
    build_choicebook()
    #m_choicebook3.set_selection(n_posit-1)
  end
  
  def clearFormAdd
    if !dialogConfirmAction?("ATTENTION! Do you want to clear form for save new note?. Please confirm.","Confirm clear", Wx::ICON_QUESTION)
        return 
    end
    add_to_subvol.clear
    m_textctrl13.clear
  end
  
  def addSeparator
    sepa = "\n" + ("-" * 85)
    text = m_textctrl13.get_value()
    text = text + sepa
    m_textctrl13.clear
    m_textctrl13.set_value(text)
  end
  
  def is_synch?
    ##придумать алгоримт синхронизации, при котором на сервере и на клиенте будет
    ##вестись файл-аудита, в котором первой строчкой будет запись о версии этого файла
    ##при внесении изменений(добавление/редактирование секций и заметок) версия локального файла будет изменятся
    ##при синхронизации версия файла то же будет изменятся(если пулил то такая же как на сервере, если пушим-то на сервере апдейтится (серверная + наша, ))
    ##...
    if dialogConfirmAction?("Do you want to exit from MyScratchpad?","Confirm exit", Wx::ICON_QUESTION)
      self.destroy
    end
  end

end  
 Wx::App.run do
  RubyMainFrame.new.show
  #self.RegisterHotKey(106, Wx::MOD_ALT, Wx::K_F1)
 end