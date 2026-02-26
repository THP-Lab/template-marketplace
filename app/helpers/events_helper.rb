module EventsHelper
  def event_date_range(event, format: :short)
    start_date = event.event_date
    finish_date = event.end_date

    return "—" if start_date.blank? && finish_date.blank?
    return "Jusqu’au #{l(finish_date, format: format)}" if start_date.blank?
    return l(start_date, format: format) if finish_date.blank?

    "#{l(start_date, format: format)} -> #{l(finish_date, format: format)}"
  end
end
