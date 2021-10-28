class Invite {
  String? groupId;
  String? groupName;
  bool? isInvited;
  //招待されたユーザー
  List<String>? invitedUser;

  Invite({
    this.groupId,
    this.groupName,
    this.isInvited,
    this.invitedUser,
  });
}
