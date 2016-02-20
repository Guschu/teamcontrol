module TeamsHelper
  def external_link_to(team)
    url = race_team_score_url(team.race, team.team_token)
    link_to team.team_token, url, target:'_blank', class:'monospace'
  end
end
