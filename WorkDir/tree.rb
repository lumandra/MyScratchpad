require 'yaml'
require 'ya2yaml'
module Tree
  def build_tree(nw_lb = $current_project)
    m_treectrl.delete_all_items()
    tree = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/tree.yml"))
    id_r = m_treectrl.add_root("#{$current_project}")
    check_item(id_r, nw_lb)
    #level 1    
    lev1 = tree[$current_project].keys
    note_hash_lev1 = Hash.new(0)
    $tree_label_id = Hash.new(0) 
    $tree_label_id[$current_project] = id_r    
    for sect in lev1
      sec_id_lev1 = m_treectrl.append_item(id_r, "#{sect}")
      check_item(sec_id_lev1, nw_lb)
      $tree_label_id[sect] = sec_id_lev1      
      if (tree[$current_project][sect]) != 'none'
        #list is not null elements
        note_hash_lev1[sect] = sec_id_lev1
      end 
    end
    #level 2-5
    #h = { "a" => 100, "b" => 200 }
    note_hash_lev1.each {
      |key, value| 
      lev2 = tree[$current_project][key].keys
      for sect2 in lev2
        sec_id_lev2 = m_treectrl.append_item(value, "#{sect2}")
        check_item(sec_id_lev2, nw_lb)
        $tree_label_id[sect2] = sec_id_lev2
        if (tree[$current_project][key][sect2]) != 'none'
          #level 3
          lev3 = tree[$current_project][key][sect2].keys
          for sect3 in lev3
            sec_id_lev3 = m_treectrl.append_item(sec_id_lev2, "#{sect3}")
            check_item(sec_id_lev3, nw_lb)
            $tree_label_id[sect3] = sec_id_lev3
            if (tree[$current_project][key][sect2][sect3]) != 'none'
              #level 4
              lev4 = tree[$current_project][key][sect2][sect3].keys
              for sect4 in lev4
                sec_id_lev4 = m_treectrl.append_item(sec_id_lev3, "#{sect4}")
                check_item(sec_id_lev4, nw_lb)
                $tree_label_id[sect4] = sec_id_lev4
                if (tree[$current_project][key][sect2][sect3][sect4]) != 'none'
                  #level 5
                  lev5 = tree[$current_project][key][sect2][sect3][sect4].keys
                  for sect5 in lev5
                    sec_id_lev5 = m_treectrl.append_item(sec_id_lev4, "#{sect5}")
                    check_item(sec_id_lev5, nw_lb)
                    $tree_label_id[sect5] = sec_id_lev5
                    if (tree[$current_project][key][sect2][sect3][sect4][sect5]) != 'none'
                      #level 6
                      lev6 = tree[$current_project][key][sect2][sect3][sect4][sect5].keys
                      for sect6 in lev6
                        sec_id_lev6 = m_treectrl.append_item(sec_id_lev5, "#{sect6}")
                        check_item(sec_id_lev6, nw_lb)
                        $tree_label_id[sect6] = sec_id_lev6
                        if (tree[$current_project][key][sect2][sect3][sect4][sect5][sect6]) != 'none'
                          #level 7
                          lev7 = tree[$current_project][key][sect2][sect3][sect4][sect5][sect6].keys
                          for sect7 in lev7
                            sec_id_lev7 = m_treectrl.append_item(sec_id_lev6, "#{sect7}")
                            check_item(sec_id_lev7, nw_lb)
                            $tree_label_id[sect7] = sec_id_lev7
                          end
                        end 
                      end
                    end 
                  end
                end 
              end
            end 
          end
        end 
      end
    }
    #select and open root
    m_treectrl.select_item($id_selection)
    m_treectrl.expand($id_selection)
  end
  
  def check_item(sec_id, label)
    if m_treectrl.get_item_text(sec_id) == label
      $id_selection = sec_id
    end
  end
  
  def add_tree_to_file(parents, new, get = nil, val = nil)
    tree = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/tree.yml"))
    if get != nil
      item = parents.slice!(-1)
    end
    $new = new
    case parents.length 
      when 0 
        dialogMultLines("Unfortunately you can not expand this branch more.", "Save error", Wx::ICON_ERROR)
        return false
      when 1
        then
          if  get != nil
            tree[parents[0]][$new] = val
            tree[parents[0]].delete(item)
          else          
            if tree[parents[0]] == 'none'
              tree[parents[0]] = nil
              tree[parents[0]] = Hash.new(0) 
            end
            tree[parents[0]][$new] = 'none'
          end
      when 2
        then
          if  get != nil
            tree[parents[0]][parents[1]][$new] = val
            tree[parents[0]][parents[1]].delete(item)
          else 
            if tree[parents[0]][parents[1]] == 'none'
              tree[parents[0]][parents[1]] = nil
              tree[parents[0]][parents[1]] = Hash.new(0) 
            end        
            tree[parents[0]][parents[1]][$new] = 'none'
          end
      when 3 
        then
          if  get != nil
            tree[parents[0]][parents[1]][parents[2]][$new] = val
            tree[parents[0]][parents[1]][parents[2]].delete(item)
          else 
            if tree[parents[0]][parents[1]][parents[2]] == 'none'
              tree[parents[0]][parents[1]][parents[2]] = nil
              tree[parents[0]][parents[1]][parents[2]] = Hash.new(0) 
            end        
            tree[parents[0]][parents[1]][parents[2]][$new] = 'none'
          end
      when 4
        then
          if  get != nil
            tree[parents[0]][parents[1]][parents[2]][parents[3]][$new] = val
            tree[parents[0]][parents[1]][parents[2]][parents[3]].delete(item)
          else 
            if tree[parents[0]][parents[1]][parents[2]][parents[3]] == 'none'
              tree[parents[0]][parents[1]][parents[2]][parents[3]] = nil
              tree[parents[0]][parents[1]][parents[2]][parents[3]] = Hash.new(0) 
            end  
            tree[parents[0]][parents[1]][parents[2]][parents[3]][$new] = 'none'
          end
      when 5
        then 
          if  get != nil
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][$new] = val
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]].delete(item)
          else 
            if tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]] == 'none'
              tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]] = nil
              tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]] = Hash.new(0) 
            end   
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][$new] = 'none'
          end
      when 6
        then
          if  get != nil
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][$new] = val
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]].delete(item)
          else 
            if tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]] == 'none'
              tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]] = nil
              tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]] = Hash.new(0) 
            end   
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][$new] = 'none'
          end
      when 7
        then
          if  get != nil
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][parents[6]][$new] = val
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][parents[6]].delete(item)
          else 
            if tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][parents[6]] == 'none'
              tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][parents[6]] = nil
              tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][parents[6]] = Hash.new(0) 
            end 
            tree[parents[0]][parents[1]][parents[2]][parents[3]][parents[4]][parents[5]][parents[6]][$new] = 'none'
          end
      else
        dialogMultLines("Unfortunately but you can not expand this branch more.", "Save error", Wx::ICON_ERROR)
        return false
    end
    File.open("#{Dir.pwd}/Projects/#{$current_project}/tree.yml", 'w:UTF-8') {|f| f.write(YAML::dump(tree))}
    return true
  end
  
  def delete_edit_section(new_label = nil, old_label, old_label_id, action)
    tree = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/tree.yml"))
    subvols = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml"))
    subvols_note = YAML::load(open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml"))
    items = search_item(tree, old_label, new_label)
    prnts_and_item = cnt_and_get_parents(old_label_id, old_label)
    if action == "edit"
      #replace in tree.yml
      add_tree_to_file(prnts_and_item, new_label, action, items)
      #replace in subvols.yml
      subvols[new_label] = subvols[old_label]
      subvols.delete(old_label) 
      #replace in subvols_note.yml
      sub_subvols = subvols_note[old_label]
      subvols_note[new_label] = subvols_note[old_label]
      subvols_note.delete(old_label) 
    else
      ##delete in tree.yml
      ##new_label = old_label, then remove ahahahaha 
      add_tree_to_file(prnts_and_item, old_label, action, items)
      ##delete in subvols.yml
      #delete in subvols_note.yml
      subvols_note.delete(old_label)
      #if items(children items) it is array(is not null) 
      #need will remove this item
      #ITEMS-{"TEST"=>{"EE"=>"none"}, "WE"=>"none"}
      subvols.delete(old_label) 
      if items.is_a?(Hash)
        $ret_arr = Array.new()
        get_arr_childr(items)
        $ret_arr.each do |item|
          subvols_note.delete(item)
          subvols.delete(item)          
        end
      end
    end     
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols))}
    File.open("#{Dir.pwd}/Projects/#{$current_project}/subvols_note.yml", 'w:UTF-8') {|f| f.write(YAML::dump(subvols_note))}
    #собираем новое дерево и устанавливаем текущий итем
    action == "edit" ? build_tree(new_label) : build_tree
    #m_treectrl.select_item(id_r)
  end
  
  def get_arr_childr(arr)
    arr.each do |key, value|
      $ret_arr << key
      if value.is_a?(Hash)      
        get_arr_childr(value) 
      end
    end
    return $ret_arr
  end
  
  def search_item(arr, old, new)
    arr.each do |key, value|
      if key.to_s == old
        $chld_ar = arr[key]
      end
      break if key.to_s == old
      if value.is_a?(Hash)      
        search_item(value, old, new) 
      end
    end
    return $chld_ar
  end
end