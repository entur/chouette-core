module ReferentialsHelper
  # Outputs a green check icon and the text "Oui" or a red exclamation mark
  # icon and the text "Non" based on `status`
  def line_status(line)
    case line.status
    when :deactivated
      render_icon('fa fa-exclamation-circle fa-lg text-danger', Chouette::Line.tmf('deactivated')) + Chouette::Line.tmf('deactivated')
    else
      text = if line.active_from.present?
        if line.active_until.present?
          Chouette::Line.tmf('active_between', from: l(line.active_from), to: l(line.active_until))
        else
          Chouette::Line.tmf('active_from_date', from: l(line.active_from))
        end
      elsif line.active_until.present?
        Chouette::Line.tmf('active_until_date', to: l(line.active_until))
      else
        Chouette::Line.tmf('activated')
      end
      render_icon('fa fa-check-circle fa-lg text-success', text) + text
    end
  end

  def icon_for_referential_state state
    klass = case state.to_s
    when "pending"
      'fa fa-clock-o'
    when "failed"
      'fa fa-times'
    when "archived"
      'fa fa-archive'
    else
      'sb sb-lg sb-preparing'
    end
    render_icon klass, nil
  end

  def referential_state referential, icon: true
    state_icon = icon && icon_for_referential_state(@referential.state)
    "<div class='td-block'>#{state_icon}<span>#{"referentials.states.#{referential.state}".t}</span></div>".html_safe
  end

  def decorate_referential_name(referential)
    out = ""
    out += render_urgent_referential_icon if referential.contains_urgent_offer?
    out += referential.name
    out.html_safe
  end

  def render_urgent_referential_icon
    render_icon 'fa fa-flag', Referential.tmf(:urgent), 'color: #da2f36'
  end

  def referential_status(referential)
    content_tag :span, '' do
      out = content_tag(:span, title: "referentials.states.#{referential.state}".t) do
        icon_for_referential_state(referential.state)
      end
      out
    end
  end

  def referential_overview referential
    service = ReferentialOverview.new referential, self
    render partial: "referentials/overview", locals: {referential: referential, overview: service}
  end

  def mutual_workbench workbench
    return unless workbench
    current_user.organisation.workbenches.where(workgroup_id: workbench.workgroup_id).last
  end

  def duplicate_workbench_referential_path referential
    workbench = mutual_workbench referential.workbench
    raise "Missing workbench for referential #{referential.name}" unless workbench.present?
    new_workbench_referential_path(workbench, from: referential.id)
  end
end
