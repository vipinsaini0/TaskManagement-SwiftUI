    //
    //  HomeView.swift
    //  TaskManagement
    //
    //  Created by Vipin Saini on 27/04/22.
    //
    
import SwiftUI

struct HomeView: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    @Namespace var animation
    
    //Coredate Context
    @Environment(\.managedObjectContext) var context
    //Edit button context
    @Environment(\.editMode) var editButtonContext
     
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
                // MARK: Lazy Stack With Pinned Header
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                Section {
                        // MARK: Current Week View
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10){
                            ForEach(taskModel.currentWeek,id: \.self){day in
                                VStack(spacing: 10){
                                    Text(taskModel.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                    
                                        // EEE will return day as MON,TUE,....etc
                                    Text(taskModel.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                        .opacity(taskModel.isToday(date: day) ? 1 : 0)
                                }
                                    // MARK: Foreground Style
                                .foregroundStyle(taskModel.isToday(date: day) ? .primary : .secondary)
                                .foregroundColor(taskModel.isToday(date: day) ? .white : .black)
                                    // MARK: Capsule Shape
                                .frame(width: 45, height: 90)
                                .background(
                                    ZStack{
                                            // MARK: Matched Geometry Effect
                                        if taskModel.isToday(date: day){
                                            Capsule()
                                                .fill(.black)
                                                .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                        }
                                    }
                                )
                                .contentShape(Capsule())
                                .onTapGesture {
                                        // Updating Current Day
                                    withAnimation{
                                        taskModel.currentDay = day
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    tasksView()
                } header: {
                    headerView()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        
        //MARK:- Add Button
        .overlay(
            Button(action: {
                taskModel.addNewTask.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black, in: Circle())
            })
            .padding()
            ,alignment: .bottomTrailing
        )
        .sheet(isPresented: $taskModel.addNewTask) {
            taskModel.editTask = nil
        } content: {
            NewTaskView()
                .environmentObject(taskModel)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

extension HomeView {
    
        //Header
    func headerView() -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.gray)
                
                Text("Today")
                    .font(.largeTitle.bold())
            }
            .hLeading()
            
//MARK: - Edit button
            EditButton()
        }
        .padding()
        .padding(.top, getSafeArea().top)
        .background(Color.white)
    }
    
        //Tasks View
    func tasksView() -> some View {
        
        LazyVStack(spacing: 20){
            //Converting object as Our Task Model
            DynamicFilteredView(dateToFilter: taskModel.currentDay) { (object: Task) in
                taskCardView(task: object)
            }
        }
        .padding()
        .padding(.top)
        }
   
        //Task card view
    func taskCardView(task: Task) -> some View {
        
        HStack(alignment: editButtonContext?.wrappedValue == .active ? .center : .top,spacing: 30){
            if editButtonContext?.wrappedValue == .active {
                VStack(spacing: 10) {
                    
                    if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()) {
                        Button {
                            //edit
                            taskModel.editTask = task
                            taskModel.addNewTask.toggle()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button {
                            //MARK: delete task
                        context.delete(task)
                        try? context.save()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
            } else {
                VStack(spacing: 10){
                    Circle()
                        .fill(taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) ? (task.isCompleted ? .green : .black) : .clear)
                        .frame(width: 15, height: 15)
                        .background(
                            Circle()
                                .stroke(.black,lineWidth: 1)
                                .padding(-3)
                        )
                        .scaleEffect(!taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) ? 0.8 : 1)
                    
                    Rectangle()
                        .fill(.black)
                        .frame(width: 3)
                }
            }
            
            VStack{
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(task.taskTitle ?? "")
                            .font(.title2.bold())
                        
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()
                    
                    Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "")
                }
                
                if taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) {
                        // MARK: Task Status
                    HStack(spacing: 12){
                            // MARK: Check Button
                        if !task.isCompleted {
                            Button {
                                    //Task complete
                                task.isCompleted = true
                                try? context.save()
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                                    .padding(10)
                                    .background(Color.white,in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        
                        Text(task.isCompleted ? "Marked as Completed" : "Mark Task as Completed")
                            .font(.system(size: task.isCompleted ? 14 : 16, weight: .light))
                            .foregroundColor(task.isCompleted ? .gray : .white)
                            .hLeading()
                    }
                    .padding(.top)
                }
            }
            .foregroundColor(taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) ? .white : .black)
            .padding(taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) ? 15 : 0)
            .padding(.bottom,taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color("Black")
                    .cornerRadius(25)
                    .opacity(taskModel.isCurrentDateTime(date: task.taskDate ?? Date()) ? 1 : 0)
            )
        }
        .hLeading()
    } 
}
