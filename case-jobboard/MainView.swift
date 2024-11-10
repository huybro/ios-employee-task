//
//  MainView.swift
//  case-jobboard
//
//  Created by Cao Gia Huy on 11/9/24.
//

import Foundation
import SwiftUI

// MARK: - Models
struct Job: Identifiable {
    let id = UUID()
    let title: String
    let company: String
    let matchPercentage: Int
    let zipCode: String
    let distance: Double
}

// MARK: - Constants
struct AppColors {
    static let background = Color(red: 0.95, green: 0.91, blue: 0.75) // Original beige-white
    static let title = Color(red: 0.0, green: 0.3, blue: 0.6) // Original blue
}

// MARK: - View Models
class JobListViewModel: ObservableObject {
    @Published var jobs: [Job]
    @Published var searchZipCode: String = ""
    @Published var filteredJobs: [Job] = []
    
    init() {
        self.jobs = [
            Job(title: "Solar Service Electrician", company: "ReVision Energy-Montville, ME", matchPercentage: 85, zipCode: "04941", distance: 0),
            Job(title: "Solar Electrician - Electrical Apprentice", company: "ReVision Energy-Enfield, NH", matchPercentage: 78, zipCode: "03748", distance: 0),
            Job(title: "Solar Service Electrician", company: "ReVision Energy-South Portland, ME", matchPercentage: 85, zipCode: "04106", distance: 0),
            Job(title: "Solar Electrician - Electrical Apprentice", company: "ReVision Energy", matchPercentage: 78, zipCode: "03824", distance: 0),
            Job(title: "Solar Electrician - Electrical Apprentice", company: "ReVision Energy", matchPercentage: 78, zipCode: "03106", distance: 0),
            Job(title: "Solar Electrician - Electrical Apprentice", company: "ReVision Energy", matchPercentage: 78, zipCode: "04103", distance: 0),
            Job(title: "Solar Electrician - Electrical Apprentice", company: "ReVision Energy", matchPercentage: 78, zipCode: "04401", distance: 0),
            Job(title: "Solar Electrician - Electrical Apprentice", company: "ReVision Energy", matchPercentage: 78, zipCode: "04240", distance: 0),
        ]
        self.filteredJobs = jobs
    }
    
    func filterJobs(by zipCode: String) {
        print("Filtering for ZIP code: \(zipCode)") // Debug print

        guard !zipCode.isEmpty else {
            filteredJobs = jobs
            return
        }
        
        filteredJobs = jobs.filter { job in
            job.zipCode.prefix(1) == zipCode.prefix(1)
        }
    }
}

// MARK: - Main View
struct MainView: View {
    @StateObject private var viewModel = JobListViewModel()
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchHeader
                jobList
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            Text("Job Postings")
                .font(.largeTitle)
                .foregroundColor(AppColors.title)
                .bold()
                .padding(.top, 40)
            
            ZipCodeSearchField(
                zipCode: $viewModel.searchZipCode,
                isSearching: $isSearching,
                onSubmit: { viewModel.filterJobs(by: viewModel.searchZipCode) }
            )
        }
        .padding()
        .background(AppColors.background)
    }
    
    private var jobList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.filteredJobs) { job in
                    JobCardView(job: job)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct ZipCodeSearchField: View {
    @Binding var zipCode: String
    @Binding var isSearching: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
                .foregroundColor(.gray)
            
            TextField("Enter ZIP code", text: $zipCode)
                .keyboardType(.numberPad)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: zipCode) {

                    isSearching = true
                }
            
            if !zipCode.isEmpty {
                Button(action: {
                    zipCode = ""
                    onSubmit()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .shadow(radius: 2)
    }
}

struct JobCardView: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(job.title)
                .font(.headline)
                .foregroundColor(.blue)
            
            Text(job.company)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("Match: \(job.matchPercentage)%")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    print("Tapped on job: \(job.title)")
                }) {
                    Text("Apply")
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    MainView()
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
