class UserNotifierMailer < ApplicationMailer
  default :from => 'any_from_address@example.com'

  # send a signup email to the user, pass in the user object that contains the user's email address
  def send_signup_email(user)
    @user = user
    @user_name = @user.email.split('@').first
    @signin_url = user_session_url
    mail( :to => @user.email,
    :subject => 'Thanks for signing up for our amazing app' )
  end

  # send an email to invitees to with a link of the album
  def send_album_invitation_email(album, user_email)
    @album = album
    @album_url = panel_album_url(@album)
    # @user = user
    @user_name = user_email.split('@').first
    @album_owner_email = @album.user.email
    mail( :to => user_email,
    :subject => 'You have been invited to an album.' )
  end
end
