//
//  CircularContainerView.swift
//  AssetCompressor
//
//  Created by Ray Qu on 22/02/22.
//

import SwiftUI

struct CircularContainerView<ContentView: View>: View {
    
    var id: String = UUID().uuidString
    var namespace: Namespace.ID?
    let defaultId: String = UUID().uuidString
    @Namespace private var defaultNameSpace

    var backgroundColor = Color.fromHex(0xF2F3F8)

    @State private var isPressed = false
    var onTapped: (() -> Void)?
    
    var createContentView: () -> ContentView
    
    var body: some View {
        if onTapped != nil {
            createGestureView()
        } else {
            createNonGestureView()
        }
    }
    
    private func createNonGestureView() -> some View {
        let view = ZStack {
            createContentView().padding()
        }
        .background(
            backgroundColor
                .cornerRadius(30)
                .shadow(color: Color.black.opacity(0.4), radius: 3, x: 2, y: 2)
        )
        .contentShape(Rectangle())
        .scaleEffect(isPressed && onTapped != nil ? 1.1 : 1)
        return view
    }

    private func createGestureView() -> some View {
        let view = createNonGestureView()
            .onTapGesture {
                onTapped?()
            }
            .onPressedGesture { pressed in
                withAnimation {
                    isPressed = pressed
                }
            }
        return view
    }
}

struct CircularContainerView_Previews: PreviewProvider {
    static var previews: some View {
        CircularContainerView {  Text("TestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajdsakjdaskdjaksjdasjdkasdjasljdkasljdksaljdaslkjdaskljdasjdasldjasldjasljdasjdaldjakslTestsadsajkdsajdsajdsadjsalkdsjakdjasldjasdjaskdjaskldjsajd") }
    }
}
