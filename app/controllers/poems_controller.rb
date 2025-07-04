class PoetryController < ApplicationController
  FAIL_POEM = "it seems i've failed you\n and can't show you a poem\n  but i still love you".freeze

  def index
    @poem = Poem.generate
    render :show
  end

  def show
    @poem = Poem.find_by(id: params[:id]) || FAIL_POEM
  end

  def error
    @poem = FAIL_POEM
    render :show
  end
end
