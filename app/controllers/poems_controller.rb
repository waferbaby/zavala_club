class PoemsController < ApplicationController
  def create
    @poem = Poem.generate

    render :show
  end

  def show
    @poem = Poem.find_by!(digest: params[:digest])

    respond_to do |format|
      format.html
      format.text { render plain: @poem.to_s }
      format.json { render json: { id: @poem.digest, form: @poem.form.to_s, contents: @poem.to_a } }
      format.jpeg { send_data poem_preview_data(@poem), type: "image/jpeg", disposition: "inline" }
    end
  end

  private

  def poem_preview_data(poem)
    return nil unless poem.preview.attached?

    path = ActiveStorage::Blob.service.path_for(poem.preview.key)
    return nil unless path.present? && File.exist?(path)

    File.read(path)
  end
end
