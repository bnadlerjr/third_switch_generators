  # Helper for generating a +TemplateFormBuilder+. Used just like a
  # normal +form_for+ helper. This saves you the trouble of having to write
  #   <tt>form_for :model, :builder => TemplateFormBuilder do |f|</tt>
  # all the time.
  def template_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!
    form_for(record_or_name_or_array,
      *(args << options.merge(:builder => TemplateFormBuilder)), &proc)
  end

  # Helper for generating a +TableFormBuilder+. Used just like a
  # normal +form_for+ helper. This saves you the trouble of having to write
  #   <tt>form_for :model, :builder => TableFormBuilder do |f|</tt>
  # all the time.
  def table_form_for(record_or_name_or_array, *args, &proc)
    options = args.extract_options!

    content_tag :table,
      form_for(record_or_name_or_array,
        *(args << options.merge(:builder => TableFormBuilder)), &proc)
  end
