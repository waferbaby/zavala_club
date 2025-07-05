class PoemsController < ApplicationController
  def create
    @poem = Poem.generate
    render :show
  end

  def show
    @poem = Poem.find_by!(digest: params[:id])
  end
end
