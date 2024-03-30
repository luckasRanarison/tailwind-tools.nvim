const color = "text-blue-300";

const Component = () => {
  return (
    <div>
      <div
        className="flex items-center justify-center container mx-auto p-4
        border-2 border-gray-500 rounded-md bg-gray-100"
      >
        <div className="text-2xl font-bold mb-4">
          Lorem ipsum dolor sit amet, qui minim labore adipisicing minim sint
          cillum sint consectetur cupidatat.
        </div>
        <div className={`${color} bg-gray-100`}>
          Lorem ipsum dolor sit amet, qui minim labore adipisicing minim sint
          cillum sint consectetur cupidatat.
        </div>
      </div>
    </div>
  );
};

export default Component;
