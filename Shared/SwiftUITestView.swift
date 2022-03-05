//
//  SwiftUITestView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 20/02/22.
//

import SwiftUI

struct SwiftUITestView: View {
    @Namespace private var namespace
    @State private var showDetail = true

    @State private var rotate = false

    var body: some View {
        ZStack {
            if(showDetail == false) {
                HStack {
                    Button("Test") {
                        
                    }
                   
                    Circle()
                    Circle()
                    Circle()

                    Circle()
                    Circle()
                        .matchedGeometryEffect(id: "id", in: namespace)
                        .onTapGesture {
                            withAnimation {
                                self.showDetail.toggle()
                            }
                        }
                }
//                .transition(.fly)

//
//
//
            }
            
            if showDetail {
                Color.red
                    .matchedGeometryEffect(id: "id", in: namespace)
                    .frame(width: 300, height: 300, alignment: .center)
                    .transition(.fly)
                    .onTapGesture {
                        withAnimation {
                            self.showDetail.toggle()
                        }
                    }
            }
        }
     
      
    }
}
extension View {

    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: Equatable>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}

/// An animatable modifier that is used for observing animations for a given animatable value.
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: Equatable {

    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}

struct GeometryEffectTransitionsDemo: View {
    @State private var show = false
    @Namespace var namespace
    var body: some View {
        
//        return ZStack {
//            if(selectedID != nil) {
//                VideoCompressConfigView(id: selectedID!, namespace: namespace)
//            } else {
//                createMainView()
//            }
//        }
//        return ZStack {
//
//            if(!show) {
//                Color.green
//                   .matchedGeometryEffect(id: "geoeffect1", in: namespace)
//                   .frame(height: 300)
//                   .transition(.polygonCircle)
//            }
////
////                LazyVGrid(columns: [GridItem(), GridItem()]) {
////                    if(!show) {
////                    Color.green
////                       .matchedGeometryEffect(id: "geoeffect1", in: namespace)
////                       .frame(height: 300)
////                       .transition(.polygonCircle)
////                    } else {
////                        Color.green
////                           .frame(height: 300)
////                           .opacity(!show ? 1 : 0)
////
////                    }
////
////
////                    Color.blue
////                       .frame(height: 300)
////                    Color.black
////                       .frame(height: 300)
////                }
////                .opacity(!show ? 1 : 0)
////                .onAnimationCompleted(for: show) {
////                    print("Completed ")
////                }
////                .onAppear {
////                    print("Apear ")
////
////                }
//
//
//            if(show) {
//                VStack {
//                    Color.red
//                        .matchedGeometryEffect(id: "geoeffect1", in: namespace)
//                        .frame(width: 500, height: 800)
//                }
//               .transition(.polygonTriangle)
//
//            }
//
//
//        }
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: 2)) { show.toggle() }
//        }
        
//        return ZStack {
//
//            if(!show) {
//                Color.green
//                   .matchedGeometryEffect(id: "geoeffect1", in: namespace)
//                   .frame(height: 300)
//                   .transition(.polygonCircle)
//            }
//
//            if(show) {
//                VStack {
//                    Color.red
//                        .matchedGeometryEffect(id: "geoeffect1", in: namespace)
//                        .frame(width: 500, height: 800)
//                }
//               .transition(.polygonTriangle)
//
//            }
//
//
//        }
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: 2)) { show.toggle() }
//        }
                  
        return ZStack {
            if !show {
                Color.red
                   .matchedGeometryEffect(id: "geoeffect1", in: namespace)
                    .frame(width: 400)
                    .transition(.polygonCircle)
            }
            if show {
                VStack {
                Color.green
                    .matchedGeometryEffect(id: "geoeffect1", in: namespace)
                    .frame(width: 100, height: 100)

                }
                .transition(.polygonTriangle)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 2)) { show.toggle() }

        }
//
    }
}


struct MyForm: View {
    @Binding var show: Bool

    @State private var departure = Date()
    @State private var checkin = Date()

    @State private var pets = true
    @State private var nonsmoking = true
    @State private var airport: Double = 7.3
    
    var body: some View {

        VStack {
            Text("Booking").font(.title).foregroundColor(.white)

            Form {
                DatePicker(selection: $departure, label: {
                    HStack {
                        Image(systemName: "airplane")
                        Text("Departure")
                    }
                })

                DatePicker(selection: $checkin, label: {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Check-In")
                    }
                })
                
                Toggle(isOn: $pets, label: { HStack { Image(systemName: "hare.fill"); Text("Have Pets") } })
                Toggle(isOn: $nonsmoking, label: { HStack { Image(systemName: "nosign"); Text("Non-Smoking") } })
                Text("Max Distance to Airport \(String(format: "%.2f", self.airport as Double)) km")
                Slider(value: $airport, in: 0...10) { EmptyView() }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        self.show = false
                    }
                }) {
                    HStack { Spacer(); Text("Save"); Spacer() }
                }
                
            }
        }.padding(20)
    }
}

extension AnyTransition {

    static var polygonTriangle: AnyTransition {
        AnyTransition.modifier(
            active: PolygonModifier(rotate: true, opacity: 0),
            identity: PolygonModifier(rotate: false, opacity: 1)
        )
    }

    static var polygonCircle: AnyTransition {
        AnyTransition.modifier(
            active: PolygonModifier(rotate: false, opacity: 0),
            identity: PolygonModifier(rotate: true, opacity: 1)
        )
    }

    
    struct PolygonModifier: AnimatableModifier {
        var rotate: Bool
        var opacity: Double
        
        var animatableData: Bool {
                 get { rotate }
                 set { rotate = newValue }
             }
             
        func body(content: Content) -> some View {
            debugPrint("Test")
            return content
                .rotationEffect((.degrees(rotate ? 0 : 360)))
                .opacity(opacity)
        }
    }
}
          
extension AnyTransition {
    static var fly: AnyTransition { get {
        AnyTransition.modifier(active: FlyTransition(pct: 0), identity: FlyTransition(pct: 1))
        }
    }
}

struct FlyTransition: GeometryEffect {
    var pct: Double
    
    var animatableData: Double {
        get { pct }
        set { pct = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let rotationPercent = pct
        let a = CGFloat(Angle(degrees: 90 * (1-rotationPercent)).radians)
        
        var transform3d = CATransform3DIdentity;
        transform3d.m34 = -1/max(size.width, size.height)
        
        transform3d = CATransform3DRotate(transform3d, a, 1, 0, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
        
        let affineTransform1 = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
        let affineTransform2 = ProjectionTransform(CGAffineTransform(scaleX: CGFloat(pct * 2), y: CGFloat(pct * 2)))
        
        if pct <= 0.5 {
            return ProjectionTransform(transform3d).concatenating(affineTransform2).concatenating(affineTransform1)
        } else {
            return ProjectionTransform(transform3d).concatenating(affineTransform1)
        }
    }
}
     
        
//        if showDetail {
//                ZStack {
//                    Button("Test1") {
//                        showDetail = false
//                    }
//                    .frame(width: 100, height: 100)
//                    .background(
//                        Color.green
//                            .matchedGeometryEffect(id: "color", in: namespace)
//                    )
//                    .matchedGeometryEffect(id: "id", in: namespace)
//
////                    Color.red
////                        .frame(width: 200, height: 200)
////                        .onTapGesture {
////                            showDetail = false
////                        }
////                        .matchedGeometryEffect(id: "id", in: namespace)
//                }
//
//        } else {
//
//            ZStack {
//                Button("Test2") {
//                    showDetail = true
//                }
//                .frame(width: 600, height: 600)
//                .background(
//                    Color.red
//                        .matchedGeometryEffect(id: "color", in: namespace)
//                )
//                .matchedGeometryEffect(id: "id", in: namespace)
//            }
//        }
    
//            VStack {
//                HStack {
//    //                HikeGraph(data: hike, path: \.elevation)
//    //                    .frame(width: 50, height: 30)
//
//                    VStack(alignment: .leading) {
//                        Text("title")
//                            .font(.headline)
//                        Text("Detail")
//                    }
//
//                    Spacer()
//
//                    Button {
//                        withAnimation {
//                            showDetail.toggle()
//                        }
//                    } label: {
//                        Label("Graph", systemImage: "chevron.right.circle")
//                            .labelStyle(.iconOnly)
//                            .imageScale(.large)
//                            .rotationEffect(.degrees(showDetail ? 90 : 0))
//                            .scaleEffect(showDetail ? 1.5 : 1)
//                            .padding()
//                    }
//                }
//
//
//                Color.red
//                    .frame(width: 100, height: 100)
//                    .matchedGeometryEffect(id: "id", in: namespace)
//
//
////                    .rotationEffect(.degrees(showDetail ? 360 : 0))
////                    .transition(.scale)
//
//
//    //            if showDetail {
//    //                Color.red
//    //                    .frame(width: 100, height: <#T##CGFloat?#>, alignment: <#T##Alignment#>)
//    //                    .transition(.scale)
//    ////                HikeDetail(hike: hike)
//    ////                    .transition(.slide)
//    //            }
//            }
//        }
//    }
//}

//struct SwiftUITestView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUITestView()
//    }
//}


//        ZStack {
//            if (showDetail) {
//                Text("Test1")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            } else {
//                Text("Test2")
//                    .matchedGeometryEffect(id: "title", in: namespace)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//            }
//
//        }.onTapGesture {
//            withAnimation {
//                showDetail.toggle()
//            }
//        }




//
//VStack {
//    Spacer()
//    HStack {
//        Color.red
//            .frame(width: 100, height: 100)
//        Color.orange
//            .frame(width: 100, height: 100)
//        Color.purple
//            .matchedGeometryEffect(id: "title", in: namespace)
//            .frame(width: 100, height: 100)
//        Button(action: { print("") }) {
//                           Text("item")
//                               .contentShape(Rectangle())
//                               .aspectRatio(1, contentMode: .fill)
//                               .frame(width: 100, height: 100)
//                               .background(
//                                Color.gray
//
//
//                               )
//        }
//    }
//
////                Text("Test2")
////                    .frame(maxWidth: .infinity, alignment: .leading)
////                Text("Test3")
////                    .frame(maxWidth: .infinity, alignment: .leading)
////                Text("Test4")
////                    .matchedGeometryEffect(id: "title", in: namespace)
////                    .frame(maxWidth: .infinity, alignment: .leading)
//}
//.onTapGesture {
//    withAnimation(Animation.linear(duration: 3)) {
//        showDetail.toggle()
//        rotate = true
//    }
//}
