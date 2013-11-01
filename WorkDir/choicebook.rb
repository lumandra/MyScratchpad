require 'ya2yaml'
require 'yaml'
YAML::ENGINE.yamler='psych'
module Choicebook
  def build_choicebook()
    ##clear current book
    m_choicebook3.delete_all_pages()
    subvols = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml"))
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    $subvols = subvols[$curent_item]
    if $subvols.length > 1
      $subvols.each { |title|
        if title != "none"
          text = subvols_note[$curent_item][title]
          win = Wx::Panel.new(m_choicebook3)
          st = Wx::TextCtrl.new(win,  -1, "",
               Wx::Point.new(10, 10), 
               Wx::Size.new(370, 240), 
               Wx::TE_MULTILINE | Wx::TE_READONLY, 
               Wx::DEFAULT_VALIDATOR,
               "TextCtrlNameStr")
          text = text.ya2yaml(:syck_compatible => true)
          #st.set_value(text)
          if text.rindex('|-') == nil
            text = text.slice(7, 9999*9999)
            text = text.slice(0, text.length-1)
            if (text.slice(0, 1) == "\"" && text.slice(-1, 1) == "\"")
              text = text.slice(0, text.length-1)
              text = text.slice(1, text.length-1)
            end
            st.set_value(text)
          else
            text2 = ''
            text.slice(14, 9999*9999).split('    ').each do |i|
              text2 << i
            end
            st.set_value(text2)
          end
          m_choicebook3.add_page(win, title)
        end
      }
    else
      win = Wx::Panel.new(m_choicebook3)
      st = Wx::StaticText.new(win, -1, "You have not notes in section #{$curent_item}. Please add a new notes", Wx::Point.new(10,10))      
      m_choicebook3.add_page(win, $subvols[0])
    end
  end 

  def addToSubvol(new)
    subvols = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml"))
    subvols[new] = ["none"]
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols))}
    #
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    subvols_note[new] = Hash.new(0) 
    subvols_note[new]['none'] = ['none']
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols_note))}
    return true
  end

  def add_subvol_to_file
    puts "BEGIN"
    if $note_edit == "ON"
      return editNote
    end
    #check is_empty
    if ((add_to_subvol.empty?) || (m_textctrl13.empty?))
      return dialogMultLines("Please enter attributes for new note", "Save error", Wx::ICON_ERROR)
    end
    #add title
    subvols = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml"))
    #check notes is present in this section
    puts $curent_item
    if (subvols[$curent_item].index(add_to_subvol.value) != nil)
      return dialogMultLines("Please enter another title of notes term. This name is already present in this section", "Save error", Wx::ICON_ERROR)
    end
    subvols[$curent_item] << add_to_subvol.value
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols))}
    #add text
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    text = m_textctrl13.value
    text = text.ya2yaml(:syck_compatible => true)
    subvols_note[$curent_item][add_to_subvol.value] = [m_textctrl13.value]
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols_note))}
    build_choicebook()
    n_position = get_index_item($curent_item, add_to_subvol.value)
    m_choicebook3.set_selection(n_position - 1)
    add_to_subvol.clear
    m_textctrl13.clear
    return true
  end
  
  def remove_title(label, old_title)
    subvols = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml"))
    subvols[label].delete(old_title)
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols))}
  end
  
  def remove_text_title(label, old_title)
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    subvols_note[label].delete(old_title)
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols_note))}
  end
  
  def search_note(search_v)
    #get current section
    cur_sel = m_treectrl.get_selection()
	cur_sel_lbl = m_treectrl.get_item_text(cur_sel)
    #definition of subsection
    $children_arr = Array.new()
    $children_arr << cur_sel_lbl
    get_all_children(m_treectrl.get_children(cur_sel))
    #start search, get all notes for selected sections
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    subvols_note.each do |key, value|
      if $children_arr.include?(key)
        i = 0
        value.each do |key1, value1|
          value1 = value1.ya2yaml(:syck_compatible => true) 
          value1.to_s.slice(/#{search_v}/i) == nil ? subvols_note[key].delete(key1) : i += 1
        end
        if i == 0
          #this section in not have occurrences, it need remove
          subvols_note.delete(key)
        end
      else
        subvols_note.delete(key)       
      end
    end  
    return subvols_note
  end
  
  def get_all_children(arr)
    for item in arr
      $children_arr << m_treectrl.get_item_text(item)
      if m_treectrl.get_children_count(item, recursively = true) > 0
        get_all_children(m_treectrl.get_children(item))
      end
    end
  end
  
  def get_index_item(section, nots)
    subvols = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml"))
	return subvols[section].index(nots)
  end
  
  def check_section?(n_section)
    $answ = false
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    subvols_note.each do |key, value|
      if key == n_section
       $answ = true
      end
    end
    return $answ
  end
  
  def get_text_for_title(cur_sel_lbl, title)
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    text = subvols_note[cur_sel_lbl][title]
    text = text.ya2yaml(:syck_compatible => true)
    if text.rindex('|-') == nil
      text = text.slice(7, 9999*9999)
      text = text.slice(0, text.length-1)
      if (text.slice(0, 1) == "\"" && text.slice(-1, 1) == "\"")
        text = text.slice(0, text.length-1)
        text = text.slice(1, text.length-1)
      end
      return text
    else
      text2 = ''
      text.slice(14, 9999*9999).split('    ').each do |i|
        text2 << i
      end
      text2.slice!(-1, 1)
      return text2
    end
  end
end