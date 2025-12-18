//
//  check_entitlements.swift
//  StartToSwiftUI
//
//  Created by Andrey Efimov on 18.12.2025.
//

import Foundation
import CloudKit
import Security

func checkRuntimeEntitlements() {
    print("=== Checking Runtime Entitlements ===")
    
    let bundle = Bundle.main
    print("Bundle ID: \(bundle.bundleIdentifier ?? "none")")
    print("Bundle path: \(bundle.bundlePath)")
    
    // Проверка CloudKit доступности
    checkCloudKitAvailability()
}

func checkCloudKitAvailability() {
    print("\n=== CloudKit Direct Test ===")
    
    // Пробуем простейший вызов
    let container = CKContainer.default()
    
    // Важно: используем async/await для iOS 15+
    Task {
        do {
            let status = try await container.accountStatus()
            print("✅ CloudKit account status: \(status.rawValue)")
            print("✅ Status description: \(statusDescription(status))")
            
            if status == .available {
                print("✅ CloudKit доступен!")
                // Попробуем создать тестовую запись
                await createTestRecord()
            } else {
                print("⚠️ CloudKit не доступен: \(statusDescription(status))")
                
                // Если временно недоступен, ждем и проверяем снова
                if status == .temporarilyUnavailable {
                    print("⏳ Ждем 3 секунды и проверяем снова...")
                    try await Task.sleep(nanoseconds: 3_000_000_000)
                    await checkCloudKitAvailability()
                }
            }
        } catch {
            print("❌ CloudKit error: \(error.localizedDescription)")
            print("Full error: \(error)")
            
            // Если ошибка entitlements, показываем дополнительную информацию
            if error.localizedDescription.contains("entitlement") {
                print("\n=== ENTITLEMENTS ERROR DETECTED ===")
                print("Это означает, что entitlements не применяются в runtime.")
                print("Попробуйте:")
                print("1. Удалить приложение с устройства")
                print("2. Product → Clean Build Folder")
                print("3. Перезапустить Xcode")
                print("4. Собрать заново")
            }
        }
    }
}

func statusDescription(_ status: CKAccountStatus) -> String {
    switch status {
    case .available: return "Available"
    case .noAccount: return "No iCloud Account"
    case .restricted: return "Restricted"
    case .couldNotDetermine: return "Could Not Determine"
    case .temporarilyUnavailable: return "Temporarily Unavailable"
    @unknown default: return "Unknown"
    }
}

func createTestRecord() async {
    print("\n=== Creating Test Record ===")
    
    let publicDB = CKContainer.default().publicCloudDatabase
    let recordID = CKRecord.ID(recordName: "test_record_\(UUID().uuidString)")
    let record = CKRecord(recordType: "TestRecord", recordID: recordID)
    record["testField"] = "Test value from app at \(Date())"
    
    do {
        _ = try await publicDB.save(record)
        print("✅ Test record saved successfully!")
        print("Record ID: \(recordID.recordName)")
        print("Record type: TestRecord")
    } catch {
        print("❌ Failed to save test record: \(error.localizedDescription)")
    }
}

// Упрощенная проверка для быстрого теста
func quickCloudKitCheck() {
    CKContainer.default().accountStatus { status, error in
        DispatchQueue.main.async {
            if let error = error {
                print("❌ Quick check error: \(error)")
                return
            }
            
            let description: String
            switch status {
            case .available: description = "✅ Available"
            case .noAccount: description = "❌ No iCloud Account"
            case .restricted: description = "⚠️ Restricted"
            case .couldNotDetermine: description = "❓ Could Not Determine"
            case .temporarilyUnavailable: description = "⏳ Temporarily Unavailable"
            @unknown default: description = "❓ Unknown"
            }
            
            print("Quick CloudKit check: \(description)")
        }
    }
}

// Вызовите при запуске
//checkRuntimeEntitlements()
//quickCloudKitCheck()
