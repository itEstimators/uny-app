import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uny_app/Photo%20Video%20Upload%20Pages/upload_video_page.dart';

class UploadPhotoPage extends StatefulWidget{

  @override
  _UploadPhotoPageState createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage>{

  late double height;
  late double width;

  final ImagePicker _picker = ImagePicker();

  File? image;

  List<String?> imagesList = [];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          height = constraints.maxHeight;
          width = constraints.maxWidth;
          return ResponsiveWrapper.builder(
              Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: mainBody(),
              ),
              defaultScale: true,
              breakpoints: [
                const ResponsiveBreakpoint.resize(480, name: MOBILE),
                const ResponsiveBreakpoint.autoScale(720, name: MOBILE)
              ]
          );
        }
    );
  }

  Widget mainBody() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
              top: height / 8, left: width / 10, right: width / 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Загрузи своё фото',
                  style: TextStyle(fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              SizedBox(
                width: width,
                height: 40,
                child: Text(
                  'Удерживайте и перетаскивайте фото для изменения их порядка',
                  maxLines: 2,
                  style: TextStyle(fontSize: 17, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
        ReorderableGridView.count(
          padding: EdgeInsets.only(top: height / 50, left: width / 20, right: width / 20, bottom: height / 50),
          childAspectRatio: (width / 3) / (height / 4),
          crossAxisSpacing: width / 50,
          mainAxisSpacing: height / 80,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(9, (index) {
            return GestureDetector(
              key: ValueKey(index),
              onTap: () async {
                if(UniversalPlatform.isIOS){
                  var status = await Permission.photos.request();
                  if (status.isGranted) {
                    showBottomSheet();
                  } else if (status.isPermanentlyDenied) {
                    showAlertDialog();
                  }
                }else if(UniversalPlatform.isAndroid){
                  var storagePermission = await Permission.storage.request();
                  var photosPermission = await Permission.photos.request();
                  if(storagePermission.isGranted && photosPermission.isGranted){
                    showBottomSheet();
                  }else{
                    showAlertDialog();
                  }
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double? dHeight = constraints.maxHeight;
                  double? dWidth = constraints.maxWidth;
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: index != 0
                              ? Colors.grey.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.4),
                          borderRadius: BorderRadius.all(
                              Radius.circular(10)),
                          border: Border.all(
                              color: index == 0 ? Colors.orange
                                  .withOpacity(0.4) : Colors.transparent
                          ),
                          image: imagesList.asMap().containsKey(index)
                              ? DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(File(imagesList[index]!)),
                          )
                              : null,
                        ),
                        child: !imagesList.asMap().containsKey(index)
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                CupertinoIcons.add_circled_solid,
                                color: index != 0 ? Colors.grey
                                    .withOpacity(0.2) : Colors.orange
                                    .withOpacity(0.9)),
                            SizedBox(height: 3),
                            Text(
                                index != 0
                                    ? 'Нажмите для загрузки'
                                    : 'Фотография профиля',
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.center)
                          ],
                        )
                            : null,
                      ),
                      imagesList.asMap().containsKey(index) ? Padding(
                        padding: EdgeInsets.only(
                            top: dHeight * 0.815, left: dWidth * 0.730),
                        child: IconButton(
                          alignment: Alignment.bottomRight,
                          icon: Icon(CupertinoIcons.clear_thick_circled,
                              color: Colors.white, size: 40),
                          onPressed: () {
                            setState(() {
                              imagesList.removeAt(index);
                            });
                          },
                        ),
                      ) : Container(),
                    ],
                  );
                },
              ),
            );
          }),
          onReorder: (oldIndex, newIndex) {
            Map<int, String?>? imagesMap = imagesList.asMap();
            if(oldIndex != 0){
              if(newIndex != 0){
                if(imagesMap.containsKey(oldIndex) && imagesMap.containsKey(newIndex)){
                  setState(() {
                    final element = imagesList.removeAt(oldIndex);
                    imagesList.insert(newIndex, element);
                  });
                }
              }
            }
          },
        ),
        Container(
            alignment: Alignment.center,
            width: 230,
            height: 48,
            child: Material(
              borderRadius: BorderRadius.circular(11),
              color: imagesList.asMap().isNotEmpty
                  ? Color.fromRGBO(145, 10, 251, 5)
                  : Colors.grey.withOpacity(0.5),
              child: InkWell(
                onTap: imagesList.asMap().isEmpty ? null : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadVideoPage())
                  );
                },
                child: Container(
                  height: height * 0.10,
                  child: Center(child: Text('Далее', style: TextStyle(
                      color: imagesList.asMap().isEmpty ? Colors.white : Colors
                          .white.withOpacity(0.9), fontSize: 17))),
                ),
              ),
            )
        )
      ],
    );
  }

  void showBottomSheet() async {
    try{
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
      List<AssetEntity> media = await albums[0].getAssetListPaged(page: 0, size: 60);

      if(UniversalPlatform.isIOS){
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                actions: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: media.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    media[index].file.then((file) {
                                      _cropImage(file!.path);
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8)),
                                    child: AssetEntityImage(
                                      media[index],
                                      isOriginal: false,
                                      thumbnailFormat: ThumbnailFormat.png,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            );
                          },
                        ),
                      ),
                      CupertinoActionSheetAction(
                        child: Text(
                            'Выбрать из библиотеки', textAlign: TextAlign.center),
                        onPressed: () async {
                          XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery);
                          _cropImage(image!.path);
                        },
                      )
                    ],
                  )
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Отмена'),
                ),
              );
            }
        );
      }else if(UniversalPlatform.isAndroid){
        showModalBottomSheet(
            context: context,
            builder: (context){
              return Wrap(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: media.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    media[index].file.then((file) {
                                      _cropImage(file!.path);
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(8)),
                                    child: AssetEntityImage(
                                      media[index],
                                      isOriginal: false,
                                      thumbnailFormat: ThumbnailFormat.png,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            );
                          },
                        ),
                      ),
                      ListTile(
                        title: Text('Выбрать из библиотеки'),
                        onTap: () async {
                          XFile? image = await _picker.pickImage(
                              source: ImageSource.gallery);
                          _cropImage(image!.path);
                        },
                      ),
                      ListTile(
                          title: Text('Отмена'),
                          onTap: () => Navigator.pop(context)
                      ),
                    ],
                  )
                ],
              );
            }
        );
      }
    }on RangeError catch(_){
      if(UniversalPlatform.isIOS){
        showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Нет фото'),
                content: Center(
                  child: Text(
                      'У вас нет фотографий'),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Закрыть'),
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            }
        );
      }else if(UniversalPlatform.isAndroid){
        Widget _closeButton = TextButton(
            child: const Text(
                'Закрыть', style: TextStyle(color: Color.fromRGBO(145, 10, 251, 5))),
            onPressed: () {
              Navigator.pop(context);
            });

        AlertDialog dialog = AlertDialog(
            title: const Text('Нет фото'),
            content: const Text('У вас нет фотографий'),
            actions: [_closeButton]);

        showDialog(
            context: context,
            builder: (context) {
              return dialog;
            });
      }
    }
  }


  void _cropImage(String? filePath) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath!,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Загрузить фото',
            toolbarColor: Color.fromRGBO(145, 10, 251, 5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: true,
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Загрузить фото',
          cancelButtonTitle: 'Закрыть',
          doneButtonTitle: 'Сохранить',
          rotateButtonsHidden: true,
          aspectRatioPickerButtonHidden: true,
          rotateClockwiseButtonHidden: true,
          resetButtonHidden: true,
          rectX: 100,
          rectY: 100,
          aspectRatioLockEnabled: false,
        )
    );

    Navigator.pop(context);
    setState(() {
      imagesList.add(croppedFile!.path);
    });
  }


  void showAlertDialog() {
    if (UniversalPlatform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Нет доступа к галерии'),
              content: Center(
                child: Text(
                    'Что бы выбрать фото из галерии, предоставьте доступ'),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Закрыть'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: Text('Настройки'),
                  onPressed: () => openAppSettings(),
                )
              ],
            );
          }
      );
    } else if (UniversalPlatform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Нет доступа к галерии'),
              content: Center(
                child: Text(
                    'Что бы выбрать фото из галерии, предоставьте доступ'),
              ),
              actions: [
                FloatingActionButton.extended(
                  label: Text('Закрыть'),
                  backgroundColor: Colors.red,
                  onPressed: () => Navigator.pop(context),
                ),
                FloatingActionButton.extended(
                  label: Text('Настройки'),
                  backgroundColor: Color.fromRGBO(145, 10, 251, 5),
                  onPressed: () => openAppSettings(),
                )
              ],
            );
          }
      );
    }
  }

}