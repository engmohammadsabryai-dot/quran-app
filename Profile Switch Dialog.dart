void showProfileSwitcherDialog(BuildContext context, List<UserProfile> profiles) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleRadius(borderRadius: BorderRadius.circular(20)),
        title: const Text('اختر الملف الشخصي', textAlign: TextAlign.center),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...profiles.map((p) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: p.isChild ? Colors.orange.shade100 : Colors.teal.shade100,
                  child: Icon(p.isChild ? Icons.face_rounded : Icons.person_rounded, 
                    color: p.isChild ? Colors.deepOrange : Colors.teal),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(p.isChild ? 'وضع البطل الصغير (${p.age} سنة)' : 'الوضع القياسي'),
                onTap: () {
                  // تفعيل الحساب المختار وإعادة بناء الشاشة
                  Navigator.pop(context);
                },
              )),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                title: const Text('إضافة طفل / مستخدم جديد'),
                onTap: () {
                  // فتح نموذج إضافة مستخدم وتحديد العمر
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}