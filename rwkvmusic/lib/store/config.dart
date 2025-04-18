import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

import '../services/storage.dart';
import '../values/storage.dart';

class ConfigStore extends GetxController {
  static ConfigStore get to => Get.find();

  bool isFirstOpen = false;
  PackageInfo? _platform;
  String get version => _platform?.version ?? '-';
  bool get isRelease => const bool.fromEnvironment("dart.vm.product");
  Locale locale = const Locale('en', 'US');
  List<Locale> languages = [
    const Locale('en', 'US'),
    const Locale('zh', 'CN'),
  ];

  @override
  void onInit() {
    super.onInit();
    isFirstOpen = StorageService.to.getBool(STORAGE_DEVICE_FIRST_OPEN_KEY);
  }

  Future<void> getPlatform() async {
    _platform = await PackageInfo.fromPlatform();
  }

  // 标记用户已打开APP
  Future<bool> saveAlreadyOpen() {
    return StorageService.to.setBool(STORAGE_DEVICE_FIRST_OPEN_KEY, false);
  }

  Future<bool> savePromptsSelect(int selelct) {
    return StorageService.to.setInt(STORAGE_PROMPTS_SELECT, selelct);
  }

  Future<bool> saveRemberPromptSelect(bool isremember) {
    return StorageService.to.setBool(STORAGE_RememberPrompt_SELECT, isremember);
  }

  Future<bool> saveRemberEffectSelect(bool isremember) {
    return StorageService.to.setBool(STORAGE_RememberEffect_SELECT, isremember);
  }

  Future<bool> saveAutoNext(bool isremember) {
    return StorageService.to.setBool(STORAGE_AutoNext_SELECT, isremember);
  }

  Future<bool> saveSoundsEffectSelect(int selelct) {
    return StorageService.to.setInt(STORAGE_SOUNDSEFFECT_SELECT, selelct);
  }

  int getPromptsSelect() {
    return StorageService.to.getInt(STORAGE_PROMPTS_SELECT);
  }

  bool getRemberPromptSelect() {
    return StorageService.to.getBool(STORAGE_RememberPrompt_SELECT);
  }

  bool getRemberEffectSelect() {
    return StorageService.to.getBool(STORAGE_RememberEffect_SELECT);
  }

  bool getAutoNextSelect() {
    return StorageService.to.getBool(STORAGE_AutoNext_SELECT);
  }

  int getSoundsEffectSelect() {
    return StorageService.to.getInt(STORAGE_SOUNDSEFFECT_SELECT);
  }

  Future<bool> saveMidiProgramSelect(int midiProgram) {
    return StorageService.to.setInt(STORAGE_MIDIPROGRAM_SELECT, midiProgram);
  }

  int getMidiProgramSelect() {
    return StorageService.to.getInt(STORAGE_MIDIPROGRAM_SELECT);
  }

  void onInitLocale() {
    var langCode = StorageService.to.getString(STORAGE_LANGUAGE_CODE);
    if (langCode.isEmpty) return;
    var index = languages.indexWhere((element) {
      return element.languageCode == langCode;
    });
    if (index < 0) return;
    locale = languages[index];
  }

  void onLocaleUpdate(Locale value) {
    locale = value;
    Get.updateLocale(value);
    StorageService.to.setString(STORAGE_LANGUAGE_CODE, value.languageCode);
  }
}
