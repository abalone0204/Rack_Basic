class MyPagesController < Simplemvc::Controller
  def about
    "about me"
    render :about, name: "Denny", last_name: "Ku"
  end
end