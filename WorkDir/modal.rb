module ModalMessages
  def dialogMultLines(text, title, icon)
    md = Wx::MessageDialog.new(
                nil,
                "#{text}",
                "#{title}",
                icon)
    md.show_modal
  end
  
  def dialogConfirmAction?(text, title, icon)
    md = Wx::MessageDialog.new(
                nil,
                "#{text}",
                "#{title}",
                Wx::YES_NO | icon)
    if md.show_modal == Wx::ID_YES
      return true
    else
      return false
    end
  end
  
  def dialogChoice(text, title, items, answer_message, answer_title)
    dialog = Wx::SingleChoiceDialog.new(
                self,
                text,
                title,
                items,
    )
    if dialog.show_modal == Wx::ID_OK
      dialogMultLines("#{answer_message} #{dialog.get_string_selection()}", "#{answer_title}", Wx::ICON_INFORMATION)
      return dialog.get_string_selection()
    end  
    return false
    exit
  end
  
  def dialogTextEntry(text, title)
    dialog = Wx::TextEntryDialog.new(self,
                                 text,
                                 title,
                                 "",
    )
    if dialog.show_modal == Wx::ID_OK
      dialogMultLines("You create a new project: #{dialog.get_value()}", "New project", Wx::ICON_INFORMATION)
      return dialog.get_value()
    end
  end
end