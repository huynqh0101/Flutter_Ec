import 'package:flutter/material.dart';
import 'package:untitled/core/app_export.dart';
import 'package:untitled/model/address_model.dart';
import 'package:untitled/model/user.dart';
import 'package:untitled/services/address_service/address_repository.dart';
import 'package:untitled/services/address_service/address_service.dart';
import 'package:untitled/services/user_service.dart';
import 'package:untitled/theme/custom_text_style.dart';
import 'package:untitled/widgets/custom_elevated_button.dart';
import 'package:untitled/widgets/custom_text_form_field.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({
    super.key,
    required this.user,
  });

  final CustomUser user;

  @override
  State<EditInfo> createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  late AddressService addressService;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  List<Map<String, dynamic>>? provinces;
  List<Map<String, dynamic>>? districts;
  List<Map<String, dynamic>>? wards;

  String? currentProvinceId;
  String? currentProvinceName;
  String? currentDistrictId;
  String? currentDistrictName;
  String? currentWardCode;
  String? currentWardName;

  AddressModel? _address;

  late AddressRepository addressRepository;

  @override
  void initState() {
    super.initState();
    addressService = AddressService();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    addressRepository = AddressRepository();
    _getCurrentAddress();

    // _loadProvinces();
  }

  Future<void> _getCurrentAddress() async {
    if (widget.user.addressId != null) {
      _address = await addressRepository.getAddressById(widget.user.addressId!);
      print('da có ID địa chỉ');
      _loadCurrentAddress();
    } else
      print('chua có ID địa chỉ');
  }

  Future<void> _loadCurrentAddress() async {
    if (_address != null) {
      setState(() {
        currentProvinceId = _address!.provinceId;
        currentProvinceName = _address!.province;
        currentDistrictId = _address!.districtId;
        currentDistrictName = _address!.district;
        currentWardCode = _address!.wardCode;
        currentWardName = _address!.ward;
      });

      print('currentProvinceId: $currentProvinceId');
      print('currentDistrictId: $currentDistrictId');
      print('currentWardCode: $currentWardCode');

      _loadProvinces();
      _loadDistricts(currentProvinceId!);
      _loadWards(currentDistrictId!);
      print('co _address');
      print(provinces);
      print(districts);
      print(wards);
    } else
      print('khong co _address');
  }

  Future<void> _loadProvinces() async {
    try {
      final data = await addressService.getAllProvinceVN();
      setState(() {
        provinces = data;
      });
    } catch (e) {
      // Xử lý lỗi khi tải tỉnh
      print("Error loading provinces: $e");
    }
  }

  Future<void> _loadDistricts(String provinceId) async {
    try {
      final data = await addressService.getDistrictOfProvinceVN(provinceId);
      setState(() {
        districts = data;
        currentDistrictId = null;
        currentDistrictName = null;
        wards = null; // Reset danh sách phường
      });
    } catch (e) {
      print("Error loading districts: $e");
    }
  }

  Future<void> _loadWards(String districtId) async {
    try {
      final data = await addressService.getWardOfDistrictOfVN(districtId);
      setState(() {
        wards = data;
        currentWardCode = null;
        currentWardName = null;
      });
    } catch (e) {
      print("Error loading wards: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Widget _buildDropdown({
    required String? currentValue,
    required List<Map<String, dynamic>>? items,
    required String hintText,
    required Function(String value) onChanged,
    required String displayKey, // Key để hiển thị tên (ví dụ: 'ProvinceName')
    required String valueKey, // Key để lấy giá trị (ví dụ: 'ProvinceID')
  }) {
    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<String>(
      value: currentValue,
      hint: Text(hintText,
          style: CustomTextStyles.labelLargePrimary.copyWith(fontSize: 16)),
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item[valueKey].toString(), // Giá trị lấy ra khi chọn
          child: Text(
            item[displayKey],
            style: CustomTextStyles.labelLargePrimary.copyWith(fontSize: 16),
          ), // Tên hiển thị
        );
      }).toList(),
      onChanged: (value) => onChanged(value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Information')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name',
                        style: CustomTextStyles.bodyMediumDeeppurpleA200
                            .copyWith(fontSize: 16)),
                    CustomTextFormField(
                      controller: _nameController,
                      hintText: "Enter your name",
                      textInputType: TextInputType.text,
                      contentPadding: EdgeInsets.all(10),
                    ),
                    SizedBox(height: 10),
                    Text('Phone',
                        style: CustomTextStyles.bodyMediumDeeppurpleA200
                            .copyWith(fontSize: 16)),
                    CustomTextFormField(
                      controller: _phoneController,
                      hintText: 'Phone',
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 40,
                child: Text(
                  'Address',
                  style: CustomTextStyles.bodyMediumDeeppurpleA200
                      .copyWith(fontSize: 20),
                ),
              ),
              _buildDropdown(
                currentValue: currentProvinceId,
                items: provinces,
                hintText:
                _address != null ? _address!.province : 'Select Province',
                displayKey: 'ProvinceName',
                // Tên hiển thị
                valueKey: 'ProvinceID',
                // Giá trị lấy ra
                onChanged: (value) {
                  setState(() {
                    currentProvinceId = value;
                    currentProvinceName = provinces!.firstWhere((province) =>
                    province['ProvinceID'].toString() ==
                        value)['ProvinceName'];
                  });
                  _loadDistricts(currentProvinceId!);
                },
              ),
              const SizedBox(height: 10),
              if (currentProvinceId != null || _address != null)
                _buildDropdown(
                  currentValue: currentDistrictId,
                  items: districts,
                  hintText:
                  _address != null ? _address!.district : 'Select District',
                  displayKey: 'DistrictName',
                  // Tên hiển thị
                  valueKey: 'DistrictID',
                  // Giá trị lấy ra
                  onChanged: (value) {
                    setState(() {
                      currentDistrictId = null;
                      currentDistrictId = value;
                      currentDistrictName = districts!.firstWhere((district) =>
                      district['DistrictID'].toString() ==
                          value)['DistrictName'];
                    });
                    _loadWards(currentDistrictId!);
                  },
                ),
              const SizedBox(height: 10),
              // if (currentDistrictId != null)
              _buildDropdown(
                currentValue: currentWardCode,
                items: wards,
                hintText: _address != null ? _address!.ward : 'Select Ward',
                displayKey: 'WardName',
                // Tên hiển thị
                valueKey: 'WardCode',
                // Giá trị lấy ra
                onChanged: (value) {
                  setState(() {
                    currentWardCode = value;
                    currentWardName = wards!.firstWhere((ward) =>
                    ward['WardCode'].toString() == value)['WardName'];
                  });
                },
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                text: 'Update',
                onPressed: () {
                  // Cập nhật dữ liệu
                  if (_nameController.text.isNotEmpty) {
                    ProfileService()
                        .updateUserName(widget.user.uid!, _nameController.text);
                  }
                  if (_phoneController.text.isNotEmpty) {
                    ProfileService().updateUserPhone(
                        widget.user.uid!, _phoneController.text);
                  }
                  if (widget.user.addressId == null) {
                    AddressModel address = AddressModel(
                      province: currentProvinceName!,
                      district: currentDistrictName!,
                      ward: currentWardName!,
                      provinceId: currentProvinceId!,
                      districtId: currentDistrictId!,
                      wardCode: currentWardCode!,
                    );
                    addressRepository.createAddressAndLinkToUser(
                        address, widget.user.uid!);
                    print('chua co dia chi');
                  } else {
                    AddressModel address = AddressModel(
                      id: widget.user.addressId,
                      province: currentProvinceName!,
                      district: currentDistrictName!,
                      ward: currentWardName!,
                      provinceId: currentProvinceId!,
                      districtId: currentDistrictId!,
                      wardCode: currentWardCode!,
                    );
                    addressRepository.updateAddress(
                        widget.user.addressId!, address);
                  }

                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}