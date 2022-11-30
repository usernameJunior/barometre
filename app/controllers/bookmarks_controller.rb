class BookmarksController < ApplicationController
  def index
    @bookmarks = Bookmark.all
  end

  def new
    @event = Event.find(params[:event_id])
  end

  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.user = current_user
    @event = Event.find(params[:event_id])
    @bookmark.event = @event
    if @bookmark.save
      redirect_to events_path
    else

    end
  end

  def destroy
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:bookmark_id)
  end
end
