class PoetryController < ApplicationController
  def index
    @poem = Poem.generate
  end

  def show
    @poem = Poem.find_by(id: params[:id])
  end
end
