class PoemsController < ApplicationController
  def create
    @poem = Poem.generate
    render :show
  end

  def show
    @poem = Poem.find_by!(digest: params[:id])

    respond_to do |format|
      format.html { }
      format.jpeg do
        send_data poem_preview_data(@poem), type: "image/jpeg", disposition: "inline"
      end
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
