package org.bigbluebutton.web.user.views {
	import flash.events.MouseEvent;
	
	import org.bigbluebutton.lib.main.models.IUserSession;
	import org.bigbluebutton.lib.user.models.User;
	import org.bigbluebutton.lib.user.models.UserList;
	import org.bigbluebutton.lib.user.services.IUsersService;
	
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class UserWindowMediator extends Mediator {
		
		[Inject]
		public var view:UserWindow;
		
		[Inject]
		public var userSession:IUserSession;
		
		[Inject]
		public var usersService:IUsersService;
		
		override public function initialize():void {
			userSession.userList.userChangeSignal.add(userChangeHandler);
			view.usersGrid.amIModerator = userSession.userList.me.role == User.MODERATOR;
			view.usersGrid.dataProvider = userSession.userList.users;
			view.changePresenterSignal.add(onChangePresenterSignal);
			view.changeMuteSignal.add(onChangeMuteSignal);
			view.kickUserSignal.add(onKickUserSignal);
			view.raiseHandButton.addEventListener(MouseEvent.CLICK, handleRaiseHandButtonClick);
		}
		
		private function userChangeHandler(user:User, type:int):void {
			if (user.me && type == UserList.RAISE_HAND) {
				view.raiseHandButton.selected = (user.status == User.RAISE_HAND);
			}
		}
		
		private function onChangePresenterSignal(userID:String):void {
			usersService.assignPresenter(userID, "temp", userSession.userId);
		}
		
		private function onChangeMuteSignal(userID:String, mute:Boolean):void {
			usersService.muteUnmuteUser(userID, mute);
		}
		
		private function onKickUserSignal(userID:String):void {
			usersService.kickUser(userID);
		}
		
		private function handleRaiseHandButtonClick(e:MouseEvent):void {
			if (view.raiseHandButton.selected) {
				usersService.emojiStatus(User.RAISE_HAND);
			} else {
				usersService.emojiStatus(User.NO_STATUS);
			}
		}
		
		override public function destroy():void {
			super.destroy();
			view.changePresenterSignal.remove(onChangePresenterSignal);
			view.changeMuteSignal.remove(onChangeMuteSignal);
			view.kickUserSignal.remove(onKickUserSignal);
			view.raiseHandButton.removeEventListener(MouseEvent.CLICK, handleRaiseHandButtonClick);
			view = null;
		}
	}
}
