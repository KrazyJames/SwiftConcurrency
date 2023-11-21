import UIKit

func fetchThumbnails() async -> [UIImage] {
    return [UIImage()]
}

func updateUI() async {
    
    // get thumbnails
    let thumbnails = await fetchThumbnails()
    
    // This will not inherit a higher task's priority
    Task.detached(priority: .background) {
        // All tasks inside will inherit the same priority
        writeToCache(images: thumbnails)
    }
}

private func writeToCache(images: [UIImage]) {
    // write to cache
}


Task {
    await updateUI()
}

// MARK: - Resoruces
// https://www.hackingwithswift.com/quick-start/concurrency/whats-the-difference-between-a-task-and-a-detached-task
