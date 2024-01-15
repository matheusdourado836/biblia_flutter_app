import 'package:biblia_flutter_app/data/annotations_dao.dart';
import 'package:biblia_flutter_app/data/theme_provider.dart';
import 'package:biblia_flutter_app/data/verses_provider.dart';
import 'package:biblia_flutter_app/main.dart';
import 'package:biblia_flutter_app/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/annotation.dart';

class AnnotationWidget extends StatefulWidget {
  final Annotation annotation;
  final List<dynamic> verses;
  final bool isEditing;

  const AnnotationWidget(
      {Key? key, required this.annotation, required this.isEditing, required this.verses})
      : super(key: key);

  @override
  State<AnnotationWidget> createState() => _AnnotationWidgetState();
}

class _AnnotationWidgetState extends State<AnnotationWidget> {
  String title = '';
  String annotationId = '';
  late VersesProvider versesProvider;
  late ThemeProvider themeProvider;
  Color dialogColor = Colors.white;
  final TextEditingController _contentController = TextEditingController();
  final ThemeColors themeColors = ThemeColors();
  bool isEditing = false;

  @override
  void initState() {
    isEditing = widget.isEditing;
    annotationId = widget.annotation.annotationId;
    versesProvider = Provider.of<VersesProvider>(navigatorKey!.currentContext!, listen: false);
    themeProvider = Provider.of<ThemeProvider>(navigatorKey!.currentContext!, listen: false);
    themeProvider.isOn ? dialogColor = Colors.white : dialogColor = const Color.fromRGBO(83,75,94, 1);
    if (widget.annotation.verseStart > 0) {
      title = '${widget.annotation.book} ${widget.annotation.chapter}:${widget.annotation.verseStart}-${widget.annotation.verseEnd}';
    } else {
      title = '${widget.annotation.book} ${widget.annotation.chapter}:${widget.annotation.verseEnd}';
    }
    _contentController.text = widget.annotation.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                IconButton(onPressed: (() {
                  showDialog(context: context, builder: (BuildContext context) {
                    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                    return AlertDialog(
                      titlePadding: const EdgeInsets.all(0),
                      title: Container(
                          height: 90,
                          color: Theme.of(context).colorScheme.primary,
                          child: Center(child: Text('${widget.annotation.book} capítulo ${widget.annotation.chapter}', style: themeColors.coloredVerse(themeProvider.isOn),))),
                      actions: null,
                      content: Container(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width * .5,
                        padding: const EdgeInsets.all(6.0),
                        child: ListView.builder(
                            itemCount: widget.verses.length,
                            itemBuilder: (context, index) {
                          return Text.rich(
                            TextSpan(
                              text: '${(index + 1).toString()}  ',
                              style: themeColors.verseNumberColor(themeProvider.isOn),
                              children: <TextSpan> [
                                TextSpan(text: widget.verses[index], style: themeColors.verseColor(themeProvider.isOn))
                              ]
                            )
                          );
                        }),
                      ),
                    );
                  });
                }), icon: const Icon(Icons.menu_book_outlined))
            ],
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_contentController.text.isNotEmpty) {
                  if (isEditing) {
                    AnnotationsDao().updateAnnotation(annotationId, _contentController.text)
                        .whenComplete(
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text('Anotação atualizada com sucesso!'),
                            ),
                          ),
                        );
                  } else {
                    final newId = const Uuid().v1();
                    final savedAnnotation = Annotation(
                        annotationId: newId,
                        title: title,
                        content: _contentController.text,
                        book: widget.annotation.book,
                        chapter: widget.annotation.chapter,
                        verseStart: widget.annotation.verseStart,
                        verseEnd: widget.annotation.verseEnd
                    );
                    AnnotationsDao().save(
                          savedAnnotation
                        ).whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(milliseconds: 1000),
                              content: Text('Anotação salva com sucesso!'),
                            ),
                          ),
                        );
                    setState(() {
                      isEditing = true;
                      annotationId = newId;
                    });
                  }
                  versesProvider.refresh();
                }
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: _contentController,
          decoration: const InputDecoration(hintText: 'Digite sua anotação aqui...'),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
          keyboardType: TextInputType.multiline,
          expands: true,
          minLines: null,
          maxLines: null,
        ),
      ),
    );
  }
}

Map<String, dynamic> obj = {
  "denounceDTO": {
    "id": 0,
    "identifier": "string",
    "name": "string",
    "image": "string",
    "idRepository": 0,
    "externalContentLoc": "string",
    "userOwner": {
      "id": 0,
      "identifier": "string",
      "name": "string",
      "image": "string",
      "idRepository": 0,
      "externalContentLoc": "string",
      "userOwner": "string",
      "contentName": "string",
      "description": "string",
      "institution": {
        "id": 0,
        "identifier": "string",
        "name": "string",
        "image": "string",
        "idRepository": 0,
        "externalContentLoc": "string",
        "userOwner": "string",
        "contentName": "string",
        "description": "string",
        "institution": "string",
        "dtRegistration": "2023-10-24T17:20:59.982Z",
        "qtAccess": 0,
        "endLive": "2023-10-24T17:20:59.982Z",
        "dayNextLive": "2023-10-24T17:20:59.982Z",
        "dayTimeNextLive": "2023-10-24T17:20:59.982Z",
        "timeStartLive": 0,
        "timeEndLive": 0,
        "startTimeAux": "string",
        "status": "INACTIVE",
        "liveStatus": "NOT_STARTED",
        "playerThumbsGenerated": true,
        "topics": [
          {
            "id": 0,
            "vlStart": 0,
            "dsTopic": "string",
            "subTopic": true,
            "startMinute": "string"
          }
        ],
        "monitoring": true,
        "idPlaylistReferer": 0,
        "playlistTypeReferer": 0,
        "idOwner": 0,
        "idOwnerContents": [
          0
        ],
        "privacy": 0,
        "qtFollow": 0,
        "qtPublications": 0,
        "code": "string",
        "entityId": "string",
        "rnpCode": "string",
        "friendlyUrl": "string",
        "imageUploadedImage": true,
        "imageRemoveThumbnail": true,
        "thumbnailContextPath": "string",
        "tpItem": "VIDEO",
        "tpItemContext": {},
        "hasChannelAssociation": true,
        "metatagTitle": "string",
        "metatagDescription": "string",
        "reproved": true,
        "statusCss": "string",
        "thumbnailPath": "string",
        "video": true,
        "controlType": "PUBLIC",
        "channelsIds": [
          0
        ]
      },
      "dtRegistration": "2023-10-24T17:20:59.982Z",
      "qtAccess": 0,
      "endLive": "2023-10-24T17:20:59.982Z",
      "dayNextLive": "2023-10-24T17:20:59.982Z",
      "dayTimeNextLive": "2023-10-24T17:20:59.982Z",
      "timeStartLive": 0,
      "timeEndLive": 0,
      "startTimeAux": "string",
      "status": "INACTIVE",
      "liveStatus": "NOT_STARTED",
      "playerThumbsGenerated": true,
      "topics": [
        {
          "id": 0,
          "vlStart": 0,
          "dsTopic": "string",
          "subTopic": true,
          "startMinute": "string"
        }
      ],
      "monitoring": true,
      "idPlaylistReferer": 0,
      "playlistTypeReferer": 0,
      "idOwner": 0,
      "idOwnerContents": [
        0
      ],
      "privacy": 0,
      "qtFollow": 0,
      "qtPublications": 0,
      "fullName": "string",
      "surname": "string",
      "email": "string",
      "password": "string",
      "passwordConfirm": "string",
      "idInstitution": 0,
      "imageUploaded": true,
      "removeImage": true,
      "imageByte": "string",
      "thumbnailContextPath": "string",
      "tpItem": "VIDEO",
      "tpItemContext": {},
      "hasChannelAssociation": true,
      "metatagTitle": "string",
      "metatagDescription": "string",
      "reproved": true,
      "statusCss": "string",
      "thumbnailPath": "string",
      "video": true,
      "controlType": "PUBLIC",
      "channelsIds": [
        0
      ]
    },
    "contentName": "string",
    "description": "string",
    "institution": {
      "id": 0,
      "identifier": "string",
      "name": "string",
      "image": "string",
      "idRepository": 0,
      "externalContentLoc": "string",
      "userOwner": "string",
      "contentName": "string",
      "description": "string",
      "institution": "string",
      "dtRegistration": "2023-10-24T17:20:59.982Z",
      "qtAccess": 0,
      "endLive": "2023-10-24T17:20:59.983Z",
      "dayNextLive": "2023-10-24T17:20:59.983Z",
      "dayTimeNextLive": "2023-10-24T17:20:59.983Z",
      "timeStartLive": 0,
      "timeEndLive": 0,
      "startTimeAux": "string",
      "status": "INACTIVE",
      "liveStatus": "NOT_STARTED",
      "playerThumbsGenerated": true,
      "topics": [
        {
          "id": 0,
          "vlStart": 0,
          "dsTopic": "string",
          "subTopic": true,
          "startMinute": "string"
        }
      ],
      "monitoring": true,
      "idPlaylistReferer": 0,
      "playlistTypeReferer": 0,
      "idOwner": 0,
      "idOwnerContents": [
        0
      ],
      "privacy": 0,
      "qtFollow": 0,
      "qtPublications": 0,
      "code": "string",
      "entityId": "string",
      "rnpCode": "string",
      "friendlyUrl": "string",
      "imageUploadedImage": true,
      "imageRemoveThumbnail": true,
      "thumbnailContextPath": "string",
      "tpItem": "VIDEO",
      "tpItemContext": {},
      "hasChannelAssociation": true,
      "metatagTitle": "string",
      "metatagDescription": "string",
      "reproved": true,
      "statusCss": "string",
      "thumbnailPath": "string",
      "video": true,
      "controlType": "PUBLIC",
      "channelsIds": [
        0
      ]
    },
    "dtRegistration": "2023-10-24T17:20:59.983Z",
    "qtAccess": 0,
    "endLive": "2023-10-24T17:20:59.983Z",
    "dayNextLive": "2023-10-24T17:20:59.983Z",
    "dayTimeNextLive": "2023-10-24T17:20:59.983Z",
    "timeStartLive": 0,
    "timeEndLive": 0,
    "startTimeAux": "string",
    "status": "INACTIVE",
    "liveStatus": "NOT_STARTED",
    "playerThumbsGenerated": true,
    "topics": [
      {
        "id": 0,
        "vlStart": 0,
        "dsTopic": "string",
        "subTopic": true,
        "startMinute": "string"
      }
    ],
    "monitoring": true,
    "idPlaylistReferer": 0,
    "playlistTypeReferer": 0,
    "idOwner": 0,
    "idOwnerContents": [
      0
    ],
    "privacy": 0,
    "channels": [
      {
        "id": 0,
        "identifier": "string",
        "name": "string",
        "image": "string",
        "idRepository": 0,
        "externalContentLoc": "string",
        "userOwner": {
          "id": 0,
          "identifier": "string",
          "name": "string",
          "image": "string",
          "idRepository": 0,
          "externalContentLoc": "string",
          "userOwner": "string",
          "contentName": "string",
          "description": "string",
          "institution": {
            "id": 0,
            "identifier": "string",
            "name": "string",
            "image": "string",
            "idRepository": 0,
            "externalContentLoc": "string",
            "userOwner": "string",
            "contentName": "string",
            "description": "string",
            "institution": "string",
            "dtRegistration": "2023-10-24T17:20:59.983Z",
            "qtAccess": 0,
            "endLive": "2023-10-24T17:20:59.983Z",
            "dayNextLive": "2023-10-24T17:20:59.983Z",
            "dayTimeNextLive": "2023-10-24T17:20:59.983Z",
            "timeStartLive": 0,
            "timeEndLive": 0,
            "startTimeAux": "string",
            "status": "INACTIVE",
            "liveStatus": "NOT_STARTED",
            "playerThumbsGenerated": true,
            "topics": [
              {
                "id": 0,
                "vlStart": 0,
                "dsTopic": "string",
                "subTopic": true,
                "startMinute": "string"
              }
            ],
            "monitoring": true,
            "idPlaylistReferer": 0,
            "playlistTypeReferer": 0,
            "idOwner": 0,
            "idOwnerContents": [
              0
            ],
            "privacy": 0,
            "qtFollow": 0,
            "qtPublications": 0,
            "code": "string",
            "entityId": "string",
            "rnpCode": "string",
            "friendlyUrl": "string",
            "imageUploadedImage": true,
            "imageRemoveThumbnail": true,
            "thumbnailContextPath": "string",
            "tpItem": "VIDEO",
            "tpItemContext": {},
            "hasChannelAssociation": true,
            "metatagTitle": "string",
            "metatagDescription": "string",
            "reproved": true,
            "statusCss": "string",
            "thumbnailPath": "string",
            "video": true,
            "controlType": "PUBLIC",
            "channelsIds": [
              0
            ]
          },
          "dtRegistration": "2023-10-24T17:20:59.983Z",
          "qtAccess": 0,
          "endLive": "2023-10-24T17:20:59.983Z",
          "dayNextLive": "2023-10-24T17:20:59.983Z",
          "dayTimeNextLive": "2023-10-24T17:20:59.983Z",
          "timeStartLive": 0,
          "timeEndLive": 0,
          "startTimeAux": "string",
          "status": "INACTIVE",
          "liveStatus": "NOT_STARTED",
          "playerThumbsGenerated": true,
          "topics": [
            {
              "id": 0,
              "vlStart": 0,
              "dsTopic": "string",
              "subTopic": true,
              "startMinute": "string"
            }
          ],
          "monitoring": true,
          "idPlaylistReferer": 0,
          "playlistTypeReferer": 0,
          "idOwner": 0,
          "idOwnerContents": [
            0
          ],
          "privacy": 0,
          "qtFollow": 0,
          "qtPublications": 0,
          "fullName": "string",
          "surname": "string",
          "email": "string",
          "password": "string",
          "passwordConfirm": "string",
          "idInstitution": 0,
          "imageUploaded": true,
          "removeImage": true,
          "imageByte": "string",
          "thumbnailContextPath": "string",
          "tpItem": "VIDEO",
          "tpItemContext": {},
          "hasChannelAssociation": true,
          "metatagTitle": "string",
          "metatagDescription": "string",
          "reproved": true,
          "statusCss": "string",
          "thumbnailPath": "string",
          "video": true,
          "controlType": "PUBLIC",
          "channelsIds": [
            0
          ]
        },
        "contentName": "string",
        "description": "string",
        "institution": {
          "id": 0,
          "identifier": "string",
          "name": "string",
          "image": "string",
          "idRepository": 0,
          "externalContentLoc": "string",
          "userOwner": "string",
          "contentName": "string",
          "description": "string",
          "institution": "string",
          "dtRegistration": "2023-10-24T17:20:59.983Z",
          "qtAccess": 0,
          "endLive": "2023-10-24T17:20:59.983Z",
          "dayNextLive": "2023-10-24T17:20:59.983Z",
          "dayTimeNextLive": "2023-10-24T17:20:59.983Z",
          "timeStartLive": 0,
          "timeEndLive": 0,
          "startTimeAux": "string",
          "status": "INACTIVE",
          "liveStatus": "NOT_STARTED",
          "playerThumbsGenerated": true,
          "topics": [
            {
              "id": 0,
              "vlStart": 0,
              "dsTopic": "string",
              "subTopic": true,
              "startMinute": "string"
            }
          ],
          "monitoring": true,
          "idPlaylistReferer": 0,
          "playlistTypeReferer": 0,
          "idOwner": 0,
          "idOwnerContents": [
            0
          ],
          "privacy": 0,
          "qtFollow": 0,
          "qtPublications": 0,
          "code": "string",
          "entityId": "string",
          "rnpCode": "string",
          "friendlyUrl": "string",
          "imageUploadedImage": true,
          "imageRemoveThumbnail": true,
          "thumbnailContextPath": "string",
          "tpItem": "VIDEO",
          "tpItemContext": {},
          "hasChannelAssociation": true,
          "metatagTitle": "string",
          "metatagDescription": "string",
          "reproved": true,
          "statusCss": "string",
          "thumbnailPath": "string",
          "video": true,
          "controlType": "PUBLIC",
          "channelsIds": [
            0
          ]
        },
        "dtRegistration": "2023-10-24T17:20:59.983Z",
        "qtAccess": 0,
        "endLive": "2023-10-24T17:20:59.983Z",
        "dayNextLive": "2023-10-24T17:20:59.983Z",
        "dayTimeNextLive": "2023-10-24T17:20:59.983Z",
        "timeStartLive": 0,
        "timeEndLive": 0,
        "startTimeAux": "string",
        "status": "INACTIVE",
        "liveStatus": "NOT_STARTED",
        "playerThumbsGenerated": true,
        "topics": [
          {
            "id": 0,
            "vlStart": 0,
            "dsTopic": "string",
            "subTopic": true,
            "startMinute": "string"
          }
        ],
        "monitoring": true,
        "idPlaylistReferer": 0,
        "playlistTypeReferer": 0,
        "idOwner": 0,
        "idOwnerContents": [
          0
        ],
        "privacy": 0,
        "titles": [
          "string"
        ],
        "descriptions": [
          "string"
        ],
        "keywordsAsString": [
          "string"
        ],
        "friendlyUrl": "string",
        "password": "string",
        "domainsEmbed": "string",
        "sendModeration": true,
        "sendEmailToModerate": true,
        "showSendModerationOption": true,
        "idApplication": 0,
        "dsExIdentifier": "string",
        "dsExVersion": "string",
        "nmFileSubtitle": "string",
        "uploadedImage": true,
        "fieldErrors": [
          {
            "codes": [
              "string"
            ],
            "arguments": [
              {}
            ],
            "defaultMessage": "string",
            "objectName": "string",
            "field": "string",
            "rejectedValue": {},
            "bindingFailure": true,
            "code": "string"
          }
        ],
        "globalErrors": [
          {
            "codes": [
              "string"
            ],
            "arguments": [
              {}
            ],
            "defaultMessage": "string",
            "objectName": "string",
            "code": "string"
          }
        ],
        "itemTargetType": "NOT_MAPPED",
        "mode": "string",
        "removeThumbnail": true,
        "approve": true,
        "reproveComment": "string",
        "idVideoLive": 0,
        "idAudioLive": 0,
        "geolocationControl": 0,
        "type": "FAVORITE",
        "imageByte": "string",
        "tpControl": "PUBLIC",
        "qtFollow": 0,
        "qtPublications": 0,
        "nuUp": 0,
        "keywords": [
          "string"
        ],
        "dtModification": "2023-10-24T17:20:59.984Z",
        "coverImage": "string",
        "contentsIds": [
          "string"
        ],
        "viewMembersIds": [
          "string"
        ],
        "publisherMembersIds": [
          "string"
        ],
        "adminMembersIds": [
          "string"
        ],
        "imageUploadedImage": true,
        "imageRemoveThumbnail": true,
        "coverImageUploadedImage": true,
        "coverImageRemoveThumbnail": true,
        "removeAllMembers": true,
        "viewersToRemove": [
          "string"
        ],
        "viewersToAdd": [
          "string"
        ],
        "publishersToRemove": [
          "string"
        ],
        "publishersToAdd": [
          "string"
        ],
        "adminsToRemove": [
          "string"
        ],
        "adminsToAdd": [
          "string"
        ],
        "thumbnailContextPath": "string",
        "tpItem": "VIDEO",
        "tpItemContext": {},
        "coverImagePath": "string",
        "subjectDto": {
          "id": 0,
          "name": "string",
          "knowledgeAreaDto": {
            "id": 0,
            "name": "string"
          },
          "listCourses": [
            0
          ]
        },
        "courseDto": {
          "idCourse": 0,
          "nmCourse": "string",
          "knowledgeAreaDto": {
            "id": 0,
            "name": "string"
          }
        },
        "knowledgeAreaDto": {
          "id": 0,
          "name": "string"
        },
        "levelDto": {
          "idLevel": 0,
          "nmLevel": "string"
        },
        "podcastsIds": [
          0
        ],
        "edit": true,
        "playlistIds": [
          0
        ],
        "hasChannelAssociation": true,
        "metatagTitle": "string",
        "metatagDescription": "string",
        "reproved": true,
        "statusCss": "string",
        "thumbnailPath": "string",
        "video": true,
        "controlType": "PUBLIC",
        "channelsIds": [
          0
        ]
      }
    ],
    "targetId": 0,
    "comment": "string",
    "userName": "string",
    "email": "string",
    "registrationDate": "2023-10-24T17:20:59.984Z",
    "nuUp": 0,
    "contentDesc": "string",
    "contentType": "string",
    "idDenounceType": 0,
    "contextType": "string",
    "ownerName": "string",
    "ownerEmail": "string",
    "tpItem": "VIDEO",
    "tpItemContext": {},
    "hasChannelAssociation": true,
    "metatagTitle": "string",
    "metatagDescription": "string",
    "reproved": true,
    "statusCss": "string",
    "thumbnailPath": "string",
    "video": true,
    "controlType": "PUBLIC",
    "channelsIds": [
      0
    ]
  },
  "userIp": "string"
};
