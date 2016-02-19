module TeamsHelper
  def external_link_to(team)
    url = race_team_score_url(team.race, team.team_token)
    link_to url, url, target:'_blank'
  end
end
